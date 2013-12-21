require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/json'
require 'json'
require 'mongo'
require_relative 'lib/subs'

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
  
  get '/' do
    send_file 'public/index.html'
  end

  get '/api/subs' do
    json settings.mongo_db['subs'].find.to_a
  end

  post '/api/subs' do
    tmpfile = params[:file][:tempfile]
    filename = params[:file][:filename]

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

  get '/api/subs/:subs_id/preview' do |id|
    json settings.mongo_db['subs']
      .find_one({_id: BSON::ObjectId(id)},
        {fields: {lines: {'$slice' => [0,50]}}})
  end
  
  post '/api/subs/:subs_id' do |id|
  end

  get '/api/subs/:subs_id/lines/:line_id' do |subs, line|
    subs = settings.mongo_db['subs']
      .find_one({_id: BSON::ObjectId(subs),
                  'lines.id' => line.to_i},
                {fields: {'lines.$' => 1, _id: 0}})
    
    json subs.lines.first
  end

  post '/api/subs/:subs_id/lines/:line_id' do |subs, line|
    trans = JSON.parse(params['trans'])

    update({_id: BSON::ObjectId(subs),
             'lines.id' => line.to_i},
           {"$set" => {"lines.$.trans" => trans}}).
    find_one({_id: BSON::ObjectId(subs),
               'lines.id' => line},
             {fields: {'lines.$' => 1, _id: 0}})

    json subs.lines.first
  end

  get '/subs/?:subsId?' do
    send_file 'public/index.html'
  end
end
