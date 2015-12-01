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
# [*include_cron*]
#   Boolean. Whether to put the mdadm cronjob to /etc/cron.d/
#   /usr/share/mdadm/checkarray --cron --all --idle --quiet
#
# [*include_cron_daily*]
#   Boolean. Whether to put the mdadm cronjob to /etc/cron.daily/
#   mdadm --monitor --scan --oneshot
#
class mdadm (
  $package_name = hiera('mdadm::package_name', $mdadm::params::package_name),
  $package_ensure = hiera('mdadm::package_ensure',
                          $mdadm::params::package_ensure),
  $service_name = hiera('mdadm::service_name', $mdadm::params::service_name),
  $service_ensure = hiera('mdadm::service_ensure',
                          $mdadm::params::service_ensure),
  $service_manage = hiera('mdadm::service_manage',
                          $mdadm::params::service_manage),
  $service_hasstatus = hiera('mdadm::service_hasstatus',
                          $mdadm::params::service_hasstatus),
  $include_cron = hiera('mdadm::include_cron', $mdadm::params::include_cron),
  $include_cron_daily = hiera('mdadm::include_cron_daily', 
			  $mdadm::params::include_cron_daily),

) inherits mdadm::params {

  # validate parameters here

  anchor { 'mdadm::begin': } ->
  class { 'mdadm::install': } ->
  class { 'mdadm::config': }
  class { 'mdadm::service': } ->
  anchor { 'mdadm::end': }

  Anchor['mdadm::begin']  ~> Class['mdadm::service']
  Class['mdadm::install'] ~> Class['mdadm::service']
  Class['mdadm::config']  ~> Class['mdadm::service']
}
