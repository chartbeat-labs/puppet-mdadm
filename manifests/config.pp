# == Class mdadm::config
#
# This class is called from mdadm
#
class mdadm::config {

  if ($mdadm::include_cron) {
    file { $mdadm::params::cron_name :
      ensure => 'present',
    }
  }
}
