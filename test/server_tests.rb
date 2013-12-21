# -*- coding: utf-8 -*-
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
    @db['subs'].insert animu: 'klk', ep: 1, filename: 'klk1.ass'
    @subs = @db[:subs].find_one(filename: 'klk1.ass')

    @db['lines'].insert [{lines: 'mako pls', subs_id: @subs['_id'], id: 1,
                         trans: ['мако, ёпт']},
                         {lines: 'mako pls', subs_id: @subs['_id'], id: 2}]
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
end
