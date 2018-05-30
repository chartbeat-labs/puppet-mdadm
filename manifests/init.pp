# == Class: mdadm
#
# Full description of class mdadm here.
#
# === Parameters
#
# [*package_name*]
#   The name of the package. Default is 'mdadm'.
#
# [*package_ensure*]
#   The state of the package, 'absent', 'installed'. Can also specify the
#   package version, e.g. '1.2.3-1' to pin a version. Default is 'present'.
#
# [*service_name*]
#   The name of the mdadm monitor service. Default is 'mdadm'.
#
# [*service_ensure*]
#   Whether the service is 'running' or 'stopped'. Default is 'running'.
#
# [*service_manage*]
#   Boolean. Whether to manage the service or not. Default is true.
#
# [*service_hassstatus*]
#   Boolean. Whether the service has a status command. Default depends upon OS.
#
# [*include_cron*]
#   Boolean. Whether to ensure the mdadm cronjob exists in /etc/cron.d/
#
class mdadm (
  String $package_name                        = $mdadm::params::package_name,
  String $package_ensure                      = $mdadm::params::package_ensure,
  String $service_name                        = $mdadm::params::service_name,
  Enum['running', 'stopped'] $service_ensure  = $mdadm::params::service_ensure,
  Boolean $service_manage                     = $mdadm::params::service_manage,
  Boolean $service_hasstatus                  = $mdadm::params::service_hasstatus,
  Boolean $include_cron                       = $mdadm::params::include_cron,

) inherits mdadm::params {

  class { 'mdadm::install': } ->
  class { 'mdadm::config': } ->
  class { 'mdadm::service': }

  contain 'mdadm::install'
  contain 'mdadm::config'
  contain 'mdadm::service'
}
