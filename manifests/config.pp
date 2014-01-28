# == Class mdadm::config
#
# This class is called from mdadm
#
class mdadm::config {

  if ($mdadm::include_cron) {
    file { '/etc/cron.d/mdadm' :
      ensure => 'present',
    }
  }
}
