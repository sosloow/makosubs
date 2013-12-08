require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/json'
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
  
  post '/subs/new' do
    tmpfile = params[:file][:tempfile]
    name = params[:file][:filename]
    
    subs_col = settings.mongo_db['subs']
    unless subs_col.find_one(name: name)
      subs = {
        name: name,
        lines: Subtitles.import(tmpfile, name)
      }
      if subs[:lines]
        subs_col.insert subs 
        json subs_col.find_one(name: name)
      else
        json error: "Could not import from file"
      end
    else
      json error: "File with this name already exists"
    end
  end
end
