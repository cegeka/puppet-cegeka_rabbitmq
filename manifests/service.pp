# Class: cegeka_rabbitmq::service
#
#   This class manages the rabbitmq server service itself.
#
#   Jeff McCune <jeff@puppetlabs.com>
#
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class cegeka_rabbitmq::service(
  $service_name = 'rabbitmq-server',
  $ensure='running'
) {

  validate_re($ensure, '^(running|stopped)$')
  if $ensure == 'running' {
    Class['cegeka_rabbitmq::service'] -> Cegeka_rabbitmq_user<| |>
    Class['cegeka_rabbitmq::service'] -> Cegeka_rabbitmq_vhost<| |>
    Class['cegeka_rabbitmq::service'] -> Cegeka_rabbitmq_user_permissions<| |>
    $ensure_real = 'running'
    $enable_real = true
  } else {
    $ensure_real = 'stopped'
    $enable_real = false
  }

  service { $service_name:
    ensure     => $ensure_real,
    enable     => $enable_real,
    hasstatus  => true,
    hasrestart => true,
  }

}
