require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/json'
require "sinatra/reloader"
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
  
  post '/upload_subs' do
    tmpfile = params[:subs_file][:tempfile]
    name = params[:subs_file][:filename]
    
    json Subtitles.import(tmpfile, name)
  end
end
