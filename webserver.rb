require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/json'
require 'json'
require 'mongo'
require 'httparty'
require 'uri'

require_relative 'lib/subs'
require_relative 'lib/ann_api'

class MakoServer < Sinatra::Base
  include Mongo

  configure do
    use Rack::Session::Pool, expire_after: 2_592_000
    set :mongo_connection, MongoClient.new('localhost', 27017)
  end

  configure :development do
    set :mongo_db, settings.mongo_connection.db('mako_dev')
  end

  configure :test do
    set :mongo_db, settings.mongo_connection.db('mako_test')
  end

  configure :production do
    set :mongo_db, settings.mongo_connection.db('mako_subs')
  end

  get '/' do
    send_file 'public/index.html'
  end

  get '/api/subs' do
    json settings.mongo_db['subs'].find.to_a
  end

  post '/api/subs' do
    group = params['group'] || 'makosubs'
    animu = params['animu'].gsub(/\s+/, '_').downcase
    ext = File.extname(params[:file][:filename])

    tmpfile = params[:file][:tempfile]
    filename = "[#{group}]_#{animu}_#{params['ep']}#{ext}"

    subs_col = settings.mongo_db['subs']
    lines_col = settings.mongo_db['lines']
    unless subs_col.find_one(filename: filename)
      subs = {
        animu: params['animu'],
        ep: params['ep'],
        filename: filename
      }
      lines = Subtitles.import(tmpfile, filename)
      if lines
        subs_col.insert subs
        new_subs = subs_col.find_one(filename: filename)
        lines_col.insert lines.map { |l| l.merge(subs_id: new_subs['_id']) }
        json new_subs
      else
        json error: 'Could not import from file'
      end
    else
      json error: 'File with this name already exists'
    end
  end

  get '/api/subs/:subs_id' do |id|
    json settings.mongo_db['subs']
      .find_one(_id: BSON::ObjectId(id))
  end

  post '/api/subs/:subs_id' do |id|
    export_dir = 'public/files/subs'
    export_web_dir = '/files/subs'

    subs = settings.mongo_db['subs']
      .find_one(_id: BSON::ObjectId(id))
    lines = settings.mongo_db['lines']
      .find(subs_id: subs['_id']).sort(:id).to_a

    if Subtitles.export(lines, "#{export_dir}/#{subs['filename']}") > 0
      settings.mongo_db['subs']
        .update({_id: BSON::ObjectId(id)},
                {'$set' => {download: "#{export_web_dir}/#{subs['filename']}"}})
      json settings.mongo_db['subs']
        .find_one(_id: BSON::ObjectId(id))
    else
      status 400
      json error: 'Could not export the subs'
    end
  end

  get '/api/subs/:subs_id/lines/?' do |subs|
    subs = settings.mongo_db['subs']
      .find_one(_id: BSON::ObjectId(subs))

    json settings.mongo_db['lines']
      .find(subs_id: subs['_id']).sort(:id).to_a
  end

  get '/api/subs/:subs_id/lines/:line_id' do |subs, line|
    subs = settings.mongo_db['subs']
      .find_one(_id: BSON::ObjectId(subs))

    json settings.mongo_db['lines']
      .find_one(subs_id: subs['_id'], id: line.to_i)
  end

  post '/api/subs/:subs_id/lines/:line_id' do |subs, line|
    translated = JSON.parse(request.body.read)

    subs = settings.mongo_db['subs']
      .find_one(_id: BSON::ObjectId(subs))

    settings.mongo_db['lines']
      .update({subs_id: subs['_id'], id: line.to_i},
              {"$push" => {"trans" => translated['newTran']}})

    json settings.mongo_db['lines']
      .find_one(subs_id: subs['_id'], id: line.to_i)
  end

  post '/api/subs/:subs_id/lines/:line_id/:trans_id' do
    |subs, line, trans|
    subs = settings.mongo_db['subs']
      .find_one(_id: BSON::ObjectId(subs))

    settings.mongo_db['lines']
      .update({subs_id: subs['_id'], id: line.to_i},
              {'$set' => {"trans.#{trans}" => params['trans']}})

    json settings.mongo_db['lines']
      .find_one(subs_id: subs['_id'], id: line.to_i)
  end

  get '/api/animu/search/?' do
    json settings.mongo_db['animus']
      .find({name: /#{params['q']}/i}).to_a
  end

  get '/api/animu/annsearch/?' do
    ann_api = AnnApi::Animu.new(settings.mongo_db['animus'])
    json ann_api.search(params['q'])
  end

  get '/api/animu/:id' do |id|
    animu = settings.mongo_db['animus'].find_one(id: id)

    unless animu['episodes']
      ann_api = AnnApi::Animu.new(settings.mongo_db['animus'])
      animu = ann_api.details(id).merge(ann: true)
    end

    json animu
  end

  get '/api/threads/count' do
    count = settings.mongo_db['threads'].count
    json count: count
  end

  get '/api/threads/:page' do
    amount = 10
    json settings.mongo_db['threads']
      .find.sort(:date)
      .skip(params['page'].to_i*amount)
      .limit(amount).to_a
  end

  get '/api/threads/res/:thread_id' do |id|
    thread = settings.mongo_db['threads']
      .find_one(_id: BSON::ObjectId(id))
  end

  get '/api/threads/res/?' do
    thread = settings.mongo_db['threads']
      .insert(params)

    json settings.mongo_db['threads']
      .find_one(_id: thread)
  end

  post '/api/threads/res/:thread_id' do |id|
    thread = settings.mongo_db['threads']
      .update({_id: BSON::ObjectId(id)},
              {'$set' => {date: Time.now.to_i},
                '$push' => {posts:
                  {date: Time.now.to_i,
                    body: params['body']}}})

    json settings.mongo_db['threads']
      .find_one(_id: BSON::ObjectId(id))
  end

  get '/api/*' do
    halt 403
  end

  get '*' do
    send_file 'public/index.html'
  end
end
