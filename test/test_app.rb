#!/usr/bin/ruby

require 'rubygems'
require 'bundler'
Bundler.require

require 'app'
require 'test/unit'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_get_root
    get '/'
    assert last_response.ok?
    assert_match /\b127\.0\.0\.1\b/, last_response.body
  end
end
