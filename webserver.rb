require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/json'
require 'json'
require 'mongo'
require_relative 'lib/subs'

class MakoServer < Sinatra::Base

  include Mongo
  
  configure do
    use Rack::Session::Pool, expire_after: 2592000
    set :mongo_connection, MongoClient.new("localhost", 27017)
  end
  
  configure :development do
    set :mongo_db, settings.mongo_connection.db('mako_dev')
  end

  configure :test do
    set :mongo_db, settings.mongo_connection.db('mako_test')
    disable :show_exceptions
  end
  
  get '/' do
    send_file 'public/index.html'
  end
  
  get '/api/subs' do
    json settings.mongo_db['subs'].
      find({}, fields: ['filename', 'animu',
                        'name', 'ep']).to_a
  end

  post '/api/subs' do
  end
  
  get '/api/subs/:subs_id' do |id|
    if params['page']&&params['amount']
      page = params['page'].to_i
      amount = params['amount'].to_i
      range = [page*amount, (page+1)*amount]
      result = settings.mongo_db['subs'].
        find_one({_id: BSON::ObjectId(id)},
                 {fields: {lines: {'$slice' => range}}})
    else
      result = settings.mongo_db['subs'].
        find_one({_id: BSON::ObjectId(id)})
    end
    json result
  end

  post '/api/subs/:subs_id' do |id|
    p params
    if params['trans']&&params['lineId']
      line_id = params['lineId'].to_i
      trans = JSON.parse(params['trans'])
      result = settings.mongo_db['subs'].
        update({_id: BSON::ObjectId(id),
                 lines: {'$elemMatch' => {id: line_id}}},
               {"$set" =>
                 {"lines.$.trans" => trans}})
      json settings.mongo_db['subs'].
        find_one({_id: BSON::ObjectId(id)})
    else
      halt 400
    end
  end
  
  post '/api/script_upload' do
    tmpfile = params[:file][:tempfile]
    filename = params[:file][:filename]
    
    subs_col = settings.mongo_db['subs']
    unless subs_col.find_one(filename: filename)
      subs_info = JSON.parse(params[:subs])
      subs = {
        animu: subs_info['animu'],
        ep: subs_info['ep'],
        filename: filename,
        lines: Subtitles.import(tmpfile, filename)
      }
      if subs[:lines]
        subs_col.insert subs
        json subs_col.find_one(filename: filename)
      else
        json error: "Could not import from file"
      end
    else
      json error: "File with this name already exists"
    end
  end

  get '/subs/?:subsId?' do
    send_file 'public/index.html'
  end
end
