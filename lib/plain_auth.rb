class PlainAuth
  def initialize(credentials_dir)
    @dir = credentials_dir
    @previous_error = nil
  end

  attr_reader :previous_error

  def auth(user, pass)
    @previous_error = nil
    unless /\A[A-Za-z0-9\-]+\z/ =~ user
      @previous_error = 'invalid user'
      return false
    end
    pass == fetch(user, 'pass')
  rescue => e
    @previous_error = e
    return false
  end

  def domain(user, default_domain=nil)
    @previous_error = nil
    fetch(user, 'domain')
  rescue => e
    @previous_error = e
    return default_domain
  end

  def inc(user)
    @previous_error = nil
    count = fetch(user, 'count').to_i rescue 0
    store(user, 'count', count+1)
  rescue => e
    @previous_error = e
    return false
  end

  private

  def path(user, attr)
    File.join(@dir, user, attr)
  end

  def fetch(user, attr)
    File.read(path(user, attr)).chomp
  end

  def store(user, attr, value)
    File.open(path(user, attr), 'w') do |f|
      f.puts value
    end
    value
  end
end
