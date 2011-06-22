$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'ddns'
require 'plain_auth'

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
    @plain_auth ||= PlainAuth.new(ENV['CREDENTIALS_DIR'] || 'config/credentials')
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials &&
      @plain_auth.auth(*@auth.credentials)
  end

  def get_ddns_of(domain)
    key, = Dir.glob("named/K#{domain}.*.key")
    unless key
      raise "domain not found: #{domain.inspect}"
    end
    DynamicDns.new(domain, key, logger)
  end

  def update_ddns(host, domain, address)
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
  domain = @plain_auth.domain(user)
  update_ddns(user, domain, request.env['REMOTE_ADDR'])
  "<p>'#{h(user)}.#{h(domain)}' set to '#{h(request.env['REMOTE_ADDR'])}'.</p>\n"
end
