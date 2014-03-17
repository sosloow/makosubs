# -*- coding: utf-8 -*-
ENV['RACK_ENV'] = 'test'

require_relative '../webserver'
require_relative 'helpers'
require 'minitest/unit'
require 'minitest/mock'
require 'minitest/autorun'
require 'rack/test'
require 'pp'

class MakoServerTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  include UnitHelpers

  def app
    MakoServer
  end

  def setup
    @db = Mongo::Connection.new('localhost', 27017).db('mako_test')
    @db['subs'].insert animu: 'klk', ep: 1, filename: 'klk1.ass'
    @subs = @db[:subs].find_one(filename: 'klk1.ass')

    @db['lines'].insert [{lines: 'mako pls', subs_id: @subs['_id'], id: 1,
                           trans: ['мако, ёпт'], start: 10.77, end: 15.17},
                         {lines: 'mako pls', subs_id: @subs['_id'], id: 2,
                           start: 15.17, end: 19.17}]
    @db['threads'].insert [{op: {title: 'blah', body: 'blah'}, posts: []},
                           {op: {title: 'blah2', body: 'blah2'}, posts: []}]
    @db['animus'].insert({"id"=>"10924",
                           "gid"=>"682557990",
                           "type"=>"TV",
                           "name"=>"Melancholy of Haruhi Suzumiya",
                           "precision"=>"TV 2009 renewal",
                           "vintage"=>"2009-04-03",
                           "searched_title"=>"[The ]Melancholy of Haruhi Suzumiya"
                         })
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
    assert_equal "[makosubs]_test_animu_1.ass", response['filename']
    assert_equal 'test animu', response['animu']

    subs = @db[:subs].find_one(filename: '[makosubs]_test_animu_1.ass')
    refute_nil subs
    refute_empty @db['lines'].find(subs_id: subs['_id']).to_a
  end

  def test_lines_return_lines_of_subs
    get "/api/subs/#{@subs['_id']}/lines/"
    response = JSON.parse(last_response.body)

    refute_empty response
  end

  def test_lines_return_a_single_line_by_id
    get "/api/subs/#{@subs['_id']}/lines/1"
    response = JSON.parse(last_response.body)

    assert_equal 1, response['id']
  end

  def test_that_lines_save_posted_translation
    post "/api/subs/#{@subs['_id']}/lines/1", '{"newTran": "мако, пжлст"}'
    response = JSON.parse(last_response.body)

    assert_includes response['trans'], 'мако, пжлст'
  end

  def test_that_lines_update_posted_translation
    post "/api/subs/#{@subs['_id']}/lines/1/0", {
      trans: 'мако, пжлст'
    }
    response = JSON.parse(last_response.body)

    refute_empty response['trans']
    assert_includes response['trans'], 'мако, пжлст'
    refute_includes response['trans'], 'мако, епт'
  end

  def test_export_of_subs_to_file
    post "/api/subs/#{@subs['_id']}"

    response = JSON.parse(last_response.body)

    assert response['download']
    assert File.exists? "public/#{response['download']}"
  end

  def test_animu_search
    query = 'haruhi'
    get '/api/animu/search', { q: query}
    response = JSON.parse(last_response.body)

    assert_match /#{query}/i, response.first['name']
  end

  def test_animu_details
    id = '10924'
    data = open('test/samples/api.xml') { |f| MultiXml.parse(f.read) }

    AnnApi::Animu.stub :get, data do
      get "/api/animu/#{id}"
      response = JSON.parse(last_response.body)
      assert_equal id, response['id']
      refute_nil response['ann']

      get "/api/animu/#{id}"
      response = JSON.parse(last_response.body)
      assert_equal id, response['id']
      assert_nil response['ann']
    end
  end

  def test_ann_search
    query = 'haruhi'
    data = open('test/samples/reports.xml') { |f| MultiXml.parse(f.read) }

    AnnApi::Animu.stub :get, data do
      get '/api/animu/annsearch', {q: query}

      response = JSON.parse(last_response.body)

      assert_match /#{query}/i, response.first['name']
    end
  end

  def test_threads_count
    get '/api/threads/count'
    response = JSON.parse(last_response.body)
    assert_equal 2, response['count']
  end
end
