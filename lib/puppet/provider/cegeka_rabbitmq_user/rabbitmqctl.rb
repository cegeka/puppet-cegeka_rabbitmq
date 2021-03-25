require 'puppet'
Puppet::Type.type(:cegeka_rabbitmq_user).provide(:cegeka_rabbitmqctl) do

  has_command(:cegeka_rabbitmqctl, 'rabbitmqctl') do
     is_optional
     environment :HOME => "/tmp"
  end
  defaultfor :feature => :posix

  def self.instances
    cegeka_rabbitmqctl('list_users').split(/\n/)[1..-2].collect do |line|
      if line =~ /^(\S+)(\s+\S+|)$/
        new(:name => $1)
      else
        raise Puppet::Error, "Cannot parse invalid user line: #{line}"
      end
    end
  end

  def create
    cegeka_rabbitmqctl('add_user', resource[:name], resource[:password])
    if resource[:admin] == :true
      make_user_admin()
    end
  end

  def destroy
    cegeka_rabbitmqctl('delete_user', resource[:name])
  end

  def exists?
    out = cegeka_rabbitmqctl('list_users').split(/\n/)[1..-2].detect do |line|
      line.match(/^#{Regexp.escape(resource[:name])}(\s+\S+|)$/)
    end
  end

  # def password
  # def password=()
  def admin
    match = cegeka_rabbitmqctl('list_users').split(/\n/)[1..-2].collect do |line|
      line.match(/^#{Regexp.escape(resource[:name])}\s+\[(administrator)?\]/)
    end.compact.first
    if match
      (:true if match[1].to_s == 'administrator') || :false
    else
      raise Puppet::Error, "Could not match line '#{resource[:name]} (true|false)' from list_users (perhaps you are running on an older version of rabbitmq that does not support admin users?)"
    end
  end

  def admin=(state)
    if state == :true
      make_user_admin()
    else
      cegeka_rabbitmqctl('set_user_tags', resource[:name])
    end
  end

  def make_user_admin
    cegeka_rabbitmqctl('set_user_tags', resource[:name], 'administrator')
  end

end
