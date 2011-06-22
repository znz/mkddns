#!/usr/bin/ruby
require 'test/unit'
$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'plain_db'

class TestPlainDb < Test::Unit::TestCase
  def test_s_new
    p_db = PlainDb.new('test/credentials')
    assert_kind_of PlainDb, p_db
    assert_nil p_db.previous_error
  end

  def plain_db
    PlainDb.new('test/credentials')
  end

  def test_invalid_user
    p_db = plain_db
    assert_nil p_db.previous_error
    assert !p_db.auth('!', '!')
    assert_equal 'invalid user', p_db.previous_error
  end

  def test_not_found_user
    p_db = plain_db
    assert_nil p_db.previous_error
    assert !p_db.auth('not-found', '!')
    assert_kind_of Errno::ENOENT, p_db.previous_error
  end

  def test_invalid_pass
    p_db = plain_db
    assert_nil p_db.previous_error
    assert !p_db.auth('user', 'ng')
    assert_nil p_db.previous_error
  end

  def test_ok
    p_db = plain_db
    assert_nil p_db.previous_error
    assert p_db.auth('user', 'ok')
    assert_nil p_db.previous_error
  end

  def test_domain
    p_db = plain_db
    assert_nil p_db.previous_error
    assert_equal 'ddns.example.com', p_db.domain('user')
    assert_nil p_db.previous_error
  end

  def test_domain_not_found
    p_db = plain_db
    assert_nil p_db.previous_error
    assert_nil p_db.domain('not-found')
    assert_kind_of Errno::ENOENT, p_db.previous_error
  end

  def test_default_domain
    p_db = plain_db
    assert_nil p_db.previous_error
    assert_equal 'ddns.example.com', p_db.domain('not-found', 'ddns.example.com')
    assert_kind_of Errno::ENOENT, p_db.previous_error
  end

  def test_count
    p_db = plain_db
    assert_nil p_db.previous_error
    assert_equal 1, p_db.inc('user')
    assert_nil p_db.previous_error
    assert_equal 2, p_db.inc('user')
  ensure
    path = p_db.__send__(:path, 'user', 'count')
    if File.exist?(path)
      File.unlink(path)
    end
  end

  def test_count_failed
    p_db = plain_db
    assert_nil p_db.previous_error
    assert_equal false, p_db.inc('not-found')
    assert_kind_of Errno::ENOENT, p_db.previous_error
  end
end
