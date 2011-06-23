class PlainDb
  def initialize(hosts_dir)
    @dir = hosts_dir
    @previous_error = nil
  end

  attr_reader :previous_error

  def auth(user, pass)
    @previous_error = nil
    unless /\A[A-Za-z0-9.\-]+\z/ =~ user
      @previous_error = 'invalid user'
      return false
    end
    pass == fetch(user, 'pass')
  rescue => e
    @previous_error = e
    return false
  end

  def fqdn(user)
    @previous_error = nil
    path = File.join(@dir, user)
    case
    when File.symlink?(path)
      return File.readlink(path)
    when File.directory?(path)
      return user
    else
      @previous_error = 'no such user'
      return false
    end
  rescue => e
    @previous_error = e
    return nil
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
