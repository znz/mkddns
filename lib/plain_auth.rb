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
    pass == File.read(File.join(@dir, user, 'pass')).chomp
  rescue => e
    @previous_error = e
    return false
  end
end
