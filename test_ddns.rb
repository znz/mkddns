#!/usr/bin/ruby
require 'test/unit'
$LOAD_PATH.push File.dirname(__FILE__)
require 'ddns'

class TestDynamicDns < Test::Unit::TestCase
  LOGGER = Logger.new(STDERR)
  LOGGER.level = Logger::DEBUG

  def test_s_new
    ddns = DynamicDns.new('example.com', '/dev/null', LOGGER)
    assert !!ddns
  end

  def ddns_example_com
    key, = Dir.glob("Kddns.example.com.*.key")
    DynamicDns.new('ddns.example.com', key, LOGGER)
  end

  def test_update_ipv4
    ddns = ddns_example_com
    ddns.update('test', '192.168.0.1')
    assert_equal(['192.168.0.1'], Resolv.getaddresses('test.ddns.example.com'))
  end

  def test_delete_ipv4
    ddns = ddns_example_com
    ddns.delete('test')
    assert_equal([], Resolv.getaddresses('test.ddns.example.com'))
  end
end
