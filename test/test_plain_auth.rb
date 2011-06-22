#!/usr/bin/ruby
require 'test/unit'
$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'plain_auth'

class TestPlainAuth < Test::Unit::TestCase
  def test_s_new
    auth = PlainAuth.new('test/credentials')
    assert_kind_of PlainAuth, auth
    assert_nil auth.previous_error
  end

  def plain_auth
    PlainAuth.new('test/credentials')
  end

  def test_invalid_user
    auth = plain_auth
    assert_nil auth.previous_error
    assert !auth.auth('!', '!')
    assert_equal 'invalid user', auth.previous_error
  end

  def test_not_found_user
    auth = plain_auth
    assert_nil auth.previous_error
    assert !auth.auth('not-found', '!')
    assert_kind_of Errno::ENOENT, auth.previous_error
  end

  def test_invalid_pass
    auth = plain_auth
    assert_nil auth.previous_error
    assert !auth.auth('user', 'ng')
    assert_nil auth.previous_error
  end

  def test_ok
    auth = plain_auth
    assert_nil auth.previous_error
    assert auth.auth('user', 'ok')
    assert_nil auth.previous_error
  end

  def test_domain
    auth = plain_auth
    assert_nil auth.previous_error
    assert_equal 'ddns.example.com', auth.domain('user')
    assert_nil auth.previous_error
  end

  def test_domain_not_found
    auth = plain_auth
    assert_nil auth.previous_error
    assert_nil auth.domain('not-found')
    assert_kind_of Errno::ENOENT, auth.previous_error
  end

  def test_default_domain
    auth = plain_auth
    assert_nil auth.previous_error
    assert_equal 'ddns.example.com', auth.domain('not-found', 'ddns.example.com')
    assert_kind_of Errno::ENOENT, auth.previous_error
  end

  def test_count
    auth = plain_auth
    assert_nil auth.previous_error
    assert_equal 1, auth.inc('user')
    assert_nil auth.previous_error
    assert_equal 2, auth.inc('user')
  ensure
    path = auth.__send__(:path, 'user', 'count')
    if File.exist?(path)
      File.unlink(path)
    end
  end

  def test_count_failed
    auth = plain_auth
    assert_nil auth.previous_error
    assert_equal false, auth.inc('not-found')
    assert_kind_of Errno::ENOENT, auth.previous_error
  end
end
