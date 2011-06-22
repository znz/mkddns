#!/usr/bin/ruby
require 'test/unit'
$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'plain_auth'

class TestPlainAuth < Test::Unit::TestCase
  def test_s_new
    auth = PlainAuth.new('test/credentials')
    assert !!auth
  end

  def plain_auth
    PlainAuth.new('test/credentials')
  end

  def test_invalid_user
    auth = plain_auth
    assert !auth.auth('!', '!')
    assert_equal 'invalid user', auth.previous_error
  end

  def test_not_found_user
    auth = plain_auth
    assert !auth.auth('not-found', '!')
    assert_kind_of Errno::ENOENT, auth.previous_error
  end

  def test_invalid_pass
    auth = plain_auth
    assert !auth.auth('user', 'ng')
    assert_nil auth.previous_error
  end

  def test_ok
    auth = plain_auth
    assert auth.auth('user', 'ok')
    assert_nil auth.previous_error
  end
end
