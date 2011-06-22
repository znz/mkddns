require 'logger'
require 'resolv'

class DynamicDns
  NSUPDATE = "/usr/bin/nsupdate"
  A_TTL = "60"
  AAAA_TTL = "60"
  TXT_TTL = "3600"
  TXT_RECORD = '"v=spf1 +mx -all"'

  def initialize(domain, key_file, logger=Logger.new('log/ddns.log', 'daily'))
    @domain = domain
    @key_file = key_file
    @logger = logger
  end

  def update(host, address, aaaa=false)
    begin
      old_addresses = Resolv.getaddresses("#{host}.#{@domain}")
    rescue Resolv::ResolvError
      old_addresses = "(not found)"
    end
    if old_addresses.include?(address)
      @logger.info("ddns.update") { "host=#{host.inspect} address=#{address.inspect} (not update)" }
      return
    else
      @logger.info("ddns.update") { "host=#{host.inspect} address=#{address.inspect} old_addresses=#{old_addresses.inspect}" }
    end

    nsupdate = []
    if aaaa
      nsupdate << "update delete #{host}.#{@domain} IN AAAA"
      nsupdate << "update add #{host}.#{@domain} #{AAAA_TTL} IN AAAA #{address}"
    else
      nsupdate << "update delete #{host}.#{@domain} IN A"
      nsupdate << "update add #{host}.#{@domain} #{A_TTL} IN A #{address}"
    end
    nsupdate << "update add #{host}.#{@domain} #{TXT_TTL} IN TXT #{TXT_RECORD}"
    send(nsupdate)
  rescue Exception
    @logger.error("ddns.update") { $! }
  end

  private

  def send(nsupdate)
    @logger.debug("ddns.send") { nsupdate }
    IO.popen("-", "r+") do |io|
      if io
        # parent
        io.puts "server 127.0.0.1"
        io.puts nsupdate
        io.puts "send"
        io.close_write
        output = io.read
        if /./ =~ output
          @logger.info("ddns.nsupdate") { output }
        else
          @logger.debug("ddns.nsupdate") { "(silent)" }
        end
      else
        # child
        STDERR.reopen(STDOUT)
        argv = [NSUPDATE, "-k", @key_file]
        exec(*argv)
        @logger.error("ddns.nsupdate") { "fail to exec" }
      end
    end
  end
end
