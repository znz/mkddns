#!/usr/bin/ruby

require 'rubygems'
require 'bundler'
Bundler.require

require 'app'
require 'test/unit'
require 'rack/test'

ENV['RACK_ENV'] = 'test'
ENV['HOSTS_DIR'] = 'test/hosts'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_get_root
    get '/'
    assert last_response.ok?
    assert_match(/\b127\.0\.0\.1\b/, last_response.body)
  end

  def test_get_update_without_authentication
    get '/update'
    assert_equal 401, last_response.status
    assert_equal 'Authorization Required', last_response.body
  end

  def test_get_update_with_bad_credentials
    authorize 'user', 'ng'
    get '/update'
    assert_equal 401, last_response.status
    assert_equal 'Authorization Required', last_response.body
  end

  def test_get_update_with_proper_credentials
    authorize 'user', 'ok'
    get '/update'
    assert_equal 200, last_response.status
    assert_match(/\b127\.0\.0\.1\b/, last_response.body)
  end

  def test_get_update_fqdn_with_proper_credentials
    authorize 'user.ddns.example.com', 'ok'
    get '/update'
    assert_equal 200, last_response.status
    assert_match(/\b127\.0\.0\.1\b/, last_response.body)
  end

  def teardown
    count = File.join(ENV['HOSTS_DIR'], 'user', 'count')
    if File.exist?(count)
      File.unlink(count)
    end
  end
end
