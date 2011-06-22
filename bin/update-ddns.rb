#!/usr/bin/ruby

$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'ddns'

Dir.chdir(File.expand_path('../..', __FILE__))
require 'logger'
unless File.directory?('log')
  Dir.mkdir('log')
end
logger = Logger.new('log/update-ddns.log')
logger.level = Logger::INFO

error = proc do |msg|
  logger.fatal("update-ddns") { msg }
  raise msg
end

fqdn = ARGV.shift
unless /\A[A-Za-z0-9.\-]+\z/ =~ fqdn
  error.call("invalid fqdn: #{fqdn}")
end
host, domain = fqdn.split('.', 2)
ssh_client = ENV['SSH_CLIENT']
case ssh_client
when /\A(?:::ffff:)?(\d+\.\d+\.\d+\.\d+) \d+ \d+\z/
  ipaddr = $1
when /\A([:0-9A-Fa-f]+) \d+ \d+\z/
  ipaddr = $1
else
  error.call("unknown ssh client=#{ssh_client.inspect}")
end
logger.debug("update-ddns") { "ssh client=#{ssh_client.inspect}" }
logger.info("update-ddns") { "ssh ipaddr=#{ipaddr.inspect}" }

key, = Dir.glob("named/K#{domain}.*.key")
ddns = DynamicDns.new(domain, key, logger)
ddns.update(host, ipaddr)
