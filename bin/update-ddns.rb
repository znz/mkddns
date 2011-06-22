#!/usr/bin/ruby

$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'ddns'

require 'logger'
logger = Logger.new(STDERR)

fqdn = ARGV.shift
host, domain = fqdn.split('.', 2)
ssh_client = ENV['SSH_CLIENT']
case ssh_client
when /\A(?:::ffff:)?(\d+\.\d+\.\d+\.\d+) \d+ \d+\z/
  ipaddr = $1
when /\A([:0-9A-Fa-f]+) \d+ \d+\z/
  ipaddr = $1
else
  raise "unknown ssh client: #{ssh_client}"
end
logger.debug { "ssh client: #{ssh_client}" }
logger.info { "ipaddr: #{ipaddr}" }

key, = Dir.glob("named/K#{domain}.*.key")
ddns = DynamicDns.new(domain, key, logger)
ddns.update(host, ipaddr)
