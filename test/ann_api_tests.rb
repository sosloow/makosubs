require_relative '../webserver'
require 'minitest/unit'
require 'minitest/mock'
require 'minitest/autorun'
require 'pp'

ENV['RACK_ENV'] = 'test'

class AnnApiTest < MiniTest::Unit::TestCase
  def setup
    @db = Mongo::Connection.new('localhost', 27017).db('mako_test')
    @animu = AnnApi::Animu.new(@db['animu'])

    sample_animu = {
      "id"=>"10924",
      "gid"=>"682557990",
      "type"=>"TV",
      "name"=>"Melancholy of Haruhi Suzumiya",
      "precision"=>"TV 2009 renewal",
      "vintage"=>"2009-04-03",
      "searched_title"=>"[The ]Melancholy of Haruhi Suzumiya"
    }

    @db[:animu].insert sample_animu
  end

  def teardown
    @db.collections.each do |coll|
      coll.drop unless coll.name =~ /^system\./
    end
  end

  def test_it_caches_searched_queries
    query = 'haruhi'
    data = open('test/samples/reports.xml') { |f| MultiXml.parse(f.read) }

    AnnApi::Animu.stub :get, data do
      id = @animu.search(query).first['id']
      refute_nil @db['animu'].find_one(id: id)
    end
  end

  def test_it_updates_db_document_on_details_and_saves_image
    id = 10924
    image_dir = 'public/files/animus/'
    image_web_dir = '/files/animus/'
    data = open('test/samples/api.xml') { |f| MultiXml.parse(f.read) }

    AnnApi::Animu.stub :get, data do
      result = @animu.details(id)

      assert_equal result['id'], @db['animu'].find_one(id: id.to_s)['id']
      assert_equal result['image'], image_web_dir + 'A10924-315.jpg'
      assert File.exists?(image_dir + 'A10924-315.jpg')
    end
  end
end
