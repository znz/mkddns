#!/usr/bin/ruby
updater = File.expand_path('../update-ddns.rb', __FILE__)
open('.ssh/authorized_keys', 'w') do |out|
  puts "updating #{out.path}"
  Dir.glob('config/hosts/*/*.pub') do |filename|
    dir = File.dirname(filename)
    if File.symlink?(dir)
      puts "skip #{dir}"
      next
    end
    host = File.basename(dir)
    puts "reading #{filename}"
    key = File.open(filename) {|f| f.read }
    key.gsub!(/^/) { %Q(command="#{updater} #{host}",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ) }
    out.puts key
  end
end
