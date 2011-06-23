$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'ddns'
require 'plain_db'

helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def logger
    @logger ||= Logger.new("log/app-ddns-#{ENV['RACK_ENV']}.log", 'daily')
  end

  def protected!
    return if authorized?
    headers 'WWW-Authenticate' => %(Basic realm="Dynamic DNS")
    halt 401, 'Authorization Required'
  end

  def authorized?
    @plain_db ||= PlainDb.new(ENV['HOSTS_DIR'] || 'config/hosts')
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials &&
      @plain_db.auth(*@auth.credentials)
  end

  def get_ddns_of(domain)
    key = "config/named/#{domain}.key"
    unless File.exist?(key)
      raise "domain not found: #{domain.inspect}"
    end
    DynamicDns.new(domain, key, logger)
  end

  def update_ddns(fqdn, address)
    host, domain = fqdn.split('.', 2)
    @ddns ||= get_ddns_of(domain)
    @ddns.update(host, address)
  end
end

get '/' do
  content_type "text/html", :charset => "utf-8"
  "<p>Your IP address is '#{h(request.env['REMOTE_ADDR'])}'.</p>\n"
end

get '/update' do
  protected!
  user = @auth.username
  fqdn = @plain_db.fqdn(user)
  update_ddns(fqdn, request.env['REMOTE_ADDR'])
  @plain_db.inc(user)
  "<p>'#{h(fqdn)}' set to '#{h(request.env['REMOTE_ADDR'])}'.</p>\n"
end
