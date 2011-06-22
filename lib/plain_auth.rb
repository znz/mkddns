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

  private

  def fetch(user, attr)
    File.read(File.join(@dir, user, attr)).chomp
  end
end
