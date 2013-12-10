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
  
  get '/subs' do
    json settings.mongo_db['subs'].
      find({}, fields: ['filename', 'animu',
                        'name', 'ep']).to_a
  end

  post '/subs' do
  end
  
  post '/script_upload' do
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
      json error: "File with this name already exists", subs: JSON.parse(params[:subs])
    end
  end
end
