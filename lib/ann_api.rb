module AnnApi
  class Animu
    include HTTParty
    base_uri 'http://www.animenewsnetwork.com'

    def initialize(db_col)
      @details = {}
      @animus = db_col
    end

    def search(keyword)
      options = {query: {id: '155', type: 'anime', search: keyword}}
      result = self.class.get("/encyclopedia/reports.xml", options)
      result = result['report']['item'] if result

      if result.class == Hash
        @animus.insert(result) unless @animus.find_one(id: result['id'])
      elsif result.class == Array
        result.each do |entry|
          @animus.insert(entry) unless @animus.find_one(id: entry['id'])
        end
      end

      result
    end

    def details(id)
      animu = {}
      options = {query: {anime: id}}

      details = self.class.get("/encyclopedia/api.xml", options)
      if details
        details = format_details(details)

        @animus.update({id: details['id']}, details)
      end

      details
    end

    private
    def format_details(details)
      @details = details['ann']['anime']

      date = Date.parse(info_field('Vintage'))
      @details['date'] = Time.utc(date.year, date.month, date.day)
      @details['image'] = save_image(@details)
      @details['episodes'] = info_field('Number of episodes') || '1'
      @details['plot'] = info_field('Plot Summary')
      @details['tags'] = @details['info']
        .select { |info| ['Themes', 'Genres'].include?(info['type']) }
        .map { |info| info['__content__'] }

      %w[news release review info cast staff credit episode].each do |field|
        @details.delete(field)
      end

      @details
    end

    def save_image(animu)
      image_dir = 'public/files/animus/'
      image_web_dir = image_dir.sub('public', '')
      image_url = animu['info'].select{ |info| info['type'] == 'Picture'}.first['src']
      image_filename = File.basename(URI.parse(image_url).path)
      open(image_dir+image_filename, 'wb') do |f|
        f.write HTTParty.get(image_url).parsed_response
      end

      image_web_dir + image_filename
    end

    def xml_content(details,parent,type,filter,field)
      if details[parent].class == Array &&
          details[parent].first.class == Hash
        result = details[parent].select{ |info| info[type] == filter}
        result.first[field] if result.any?
      else
        ''
      end
    end

    def info_field(name, field='__content__')
      xml_content(@details,'info','type',name,field)
    end
  end
end
