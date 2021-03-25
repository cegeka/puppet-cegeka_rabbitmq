Puppet::Type.newtype(:cegeka_rabbitmq_plugin) do
  desc 'manages rabbitmq plugins'
  def initialize(*args)
    super
    self[:notify] = [
      "Class[cegeka_rabbitmq::service]"
    ]
    self[:require] = [
      "Package[rabbitmq-server]"
    ]
  end
  ensurable do
    defaultto(:present)
    newvalue(:present) do
      provider.create
    end
    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, :namevar => true) do
    'name of the plugin to enable'
    newvalues(/^\S+$/)
  end

end
