ENV['RACK_ENV'] = 'test'

require_relative '../webserver'
require 'minitest/unit'
require 'minitest/mock'
require 'minitest/autorun'
require 'rack/test'

class MakoTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    MakoServer
  end

  def setup
    @db = Mongo::Connection.new('localhost', 27017).db('mako_test')
  end

  def teardown
    @db.collections.each do |coll|
      coll.drop unless coll.name =~ /^system\./
    end
  end

  def test_subs_uploading_and_saving_to_mongo
    script_file = Rack::Test::UploadedFile.new('test/samples/sample.ass')

    post '/api/subs', {file: script_file,
      animu: 'test animu', ep: 1}
    response = JSON.parse(last_response.body)

    assert_nil response['error']
    assert_equal 'sample.ass', response['filename']
    assert_equal 'test animu', response['animu']

    subs = @db[:subs].find_one(filename: 'sample.ass')
    refute_nil subs
    refute_empty @db['lines'].find(subs_id: subs['_id']).to_a
  end
end
