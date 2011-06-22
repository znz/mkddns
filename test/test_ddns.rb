#!/usr/bin/ruby
require 'test/unit'
$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'ddns'

class TestDynamicDns < Test::Unit::TestCase
  LOGGER = Logger.new(STDERR)
  LOGGER.level = Logger::DEBUG

  DOMAIN = "ddns.example.com"

  def test_s_new
    ddns = DynamicDns.new('example.com', '/dev/null', LOGGER)
    assert !!ddns
  end

  def ddns_example_com
    key, = Dir.glob("named/K#{DOMAIN}.*.key")
    DynamicDns.new(DOMAIN, key, LOGGER)
  end

  def test_update_ipv4
    host = 'ipv4'
    ip = '192.168.0.1'
    ddns = ddns_example_com
    ddns.delete(host)
    assert ddns.update(host, ip)
    assert_equal([ip], Resolv.getaddresses("#{host}.#{DOMAIN}"))
    assert !ddns.update(host, ip)
    assert_equal([ip], Resolv.getaddresses("#{host}.#{DOMAIN}"))
    ddns.delete(host)
    assert_equal([], Resolv.getaddresses("#{host}.#{DOMAIN}"))
  end

  def test_update_ipv6
    host = 'ipv6'
    ip = '2001:db8::1'
    ddns = ddns_example_com
    ddns.delete(host)
    assert ddns.update(host, ip)
    assert_equal([ip], Resolv.getaddresses("#{host}.#{DOMAIN}").map{|s| s.downcase})
    assert !ddns.update(host, ip)
    assert_equal([ip], Resolv.getaddresses("#{host}.#{DOMAIN}").map{|s| s.downcase})
    ddns.delete(host)
    assert_equal([], Resolv.getaddresses("#{host}.#{DOMAIN}"))
  end
end
