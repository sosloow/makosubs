module AnnApi
  class Animu
    include HTTParty
    base_uri 'http://www.animenewsnetwork.com'

    def initialize(db_col)
      @animus = db_col
    end

    def search(keyword)
      options = {query: {id: '155', type: 'anime', search: keyword}}
      result = self.class.get("/encyclopedia/reports.xml", options)
      result = result['report']['item'] if result

      result.each do |entry|
        @animus.insert(entry) unless @animus.find_one(id: entry['id'])
      end

      result
    end

    def details(id)
      options = {query: {anime: id}}

      result = self.class.get("/encyclopedia/api.xml", options)
      result = result['ann']['anime'] if result

      result.delete('news')
      result.delete('release')
      result.delete('review')

      @animus.update({id: result['id']}, result)

      result
    end
  end
end
