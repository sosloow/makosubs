require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/json'
require "sinatra/reloader" if development?
require 'mongo'




class MakoServer < Sinatra::Base

  configure do
    use Rack::Session::Pool, expire_after: 2592000
    set :mongo_connection, MongoClient.new("localhost", 27017)
  end
  
  configure :development do
    set :mongo_db, conn.db('mako_dev')
  end

  configure :test do
    set :mongo_db, conn.db('mako_test')
    disable :show_exceptions
  end
  
  get '/' do
    send_file 'public/index.html'
  end
  
  put '/' do
    json subs
  end

  helpers do
    # a helper method to turn a string ID
    # representation into a BSON::ObjectId
    def object_id val
      BSON::ObjectId.from_string(val)
    end
  end
end



