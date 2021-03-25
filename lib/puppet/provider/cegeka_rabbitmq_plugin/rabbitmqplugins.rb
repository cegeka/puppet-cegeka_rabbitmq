Puppet::Type.type(:cegeka_rabbitmq_plugin).provide(:cegeka_rabbitmqplugins) do

  has_command(:cegeka_rabbitmqplugins, '/usr/lib/rabbitmq/bin/rabbitmq-plugins') do
     is_optional
     environment :HOME => "/tmp"
  end
  defaultfor :feature => :posix

  def self.instances
    cegeka_rabbitmqplugins('list', '-E').split(/\n/).map do |line|
      output = line.match(/^\[E\s*\]\s(\S+)\s+.\..\..$/)
      if output
        new(:name => output[1])
      else
        info("Cannot parse invalid plugins line: #{line}")
      end
    end
  end

  def create
    cegeka_rabbitmqplugins('enable', resource[:name])
  end

  def destroy
    cegeka_rabbitmqplugins('disable', resource[:name])
  end

  def exists?
    out = cegeka_rabbitmqplugins('list', '-E').split(/\n/).detect do |line|
      plugin = line.match(/^\[E\s*\]\s(\S+)\s+.\..\..$/)
      if plugin
        plugin[1].match(/^#{resource[:name]}$/)
      end
    end
  end

end
