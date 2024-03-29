Puppet::Type.type(:cegeka_rabbitmq_user_permissions).provide(:cegeka_rabbitmqctl) do

  has_command(:cegeka_rabbitmqctl, 'rabbitmqctl') do
     is_optional
     environment :HOME => "/tmp"
  end
  defaultfor :feature=> :posix

  #def self.instances
  #
  #end

  # cache users permissions
  def self.users(name, vhost)
    @users = {} unless @users
    unless @users[name]
      @users[name] = {}
      out = cegeka_rabbitmqctl('list_user_permissions', name).split(/\n/)[1..-2].each do |line|
        if line =~ /^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)$/
          @users[name][$1] =
            {:configure => $2, :read => $3, :write => $4}
        else
          raise Puppet::Error, "cannot parse line from list_user_permissions:#{line}"
        end
      end
    end
    @users[name][vhost]
  end

  def users(name, vhost)
    self.class.users(name, vhost)
  end

  def should_user
    if @should_user
      @should_user
    else
      @should_user = resource[:name].split('@')[0]
    end
  end

  def should_vhost
    if @should_vhost
      @should_vhost
    else
      @should_vhost = resource[:name].split('@')[1]
    end
  end

  def create
    resource[:configure_permission] ||= "''"
    resource[:read_permission]      ||= "''"
    resource[:write_permission]     ||= "''"
    cegeka_rabbitmqctl('set_permissions', '-p', should_vhost, should_user, resource[:configure_permission], resource[:read_permission], resource[:write_permission])
  end

  def destroy
    cegeka_rabbitmqctl('clear_permissions', '-p', should_vhost, should_user)
  end

  # I am implementing prefetching in exists b/c I need to be sure
  # that the rabbitmq package is installed before I make this call.
  def exists?
    users(should_user, should_vhost)
  end

  def configure_permission
    users(should_user, should_vhost)[:configure]
  end

  def configure_permission=(perm)
    set_permissions
  end

  def read_permission
    users(should_user, should_vhost)[:read]
  end

  def read_permission=(perm)
    set_permissions
  end

  def write_permission
    users(should_user, should_vhost)[:write]
  end

  def write_permission=(perm)
    set_permissions
  end

  # implement memoization so that we only call set_permissions once
  def set_permissions
    unless @permissions_set
      @permissions_set = true
      resource[:configure_permission] ||= configure_permission
      resource[:read_permission]      ||= read_permission
      resource[:write_permission]     ||= write_permission
      cegeka_rabbitmqctl('set_permissions', '-p', should_vhost, should_user,
        resource[:configure_permission], resource[:read_permission],
        resource[:write_permission]
      )
    end
  end

end
