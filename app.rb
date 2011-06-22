helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
  content_type "text/html", :charset => "utf-8"
  "<p>Your IP address is '#{h(request.env['REMOTE_ADDR'])}'.</p>\n"
end
