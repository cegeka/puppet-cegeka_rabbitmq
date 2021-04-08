Puppet::Type.type(:cegeka_rabbitmq_vhost).provide(:rabbitmqctl) do

  has_command(:cegeka_rabbitmqctl, 'rabbitmqctl') do
     is_optional
     environment :HOME => "/tmp"
  end
  defaultfor :feature => :posix

  def self.instances
    cegeka_rabbitmqctl('list_vhosts').split(/\n/)[1..-2].map do |line|
      if line =~ /^(\S+)$/
        new(:name => $1)
      else
        raise Puppet::Error, "Cannot parse invalid user line: #{line}"
      end
    end
  end

  def create
    cegeka_rabbitmqctl('add_vhost', resource[:name])
  end

  def destroy
    cegeka_rabbitmqctl('delete_vhost', resource[:name])
  end

  def exists?
    out = cegeka_rabbitmqctl('list_vhosts').split(/\n/)[1..-2].detect do |line|
      line.match(/^#{Regexp.escape(resource[:name])}$/)
    end
  end

end
