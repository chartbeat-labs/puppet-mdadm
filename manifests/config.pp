# == Class mdadm::config
#
# This class is called from mdadm
#
class mdadm::config {

  $cron_ensure = $mdadm::include_cron ? {
    true  => present,
    false => absent,
  }

  $cron_daily_ensure = $mdadm::include_cron_daily ? {
    true  => present,
    false => absent,
  }

  file { '/etc/cron.d/mdadm' :
    ensure => $cron_ensure,
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/mdadm/etc_cron_d_mdadm',
  }

  file { '/etc/cron.daily/mdadm' :
    ensure => $cron_daily_ensure,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/mdadm/etc_cron_daily_mdadm',
  }

}
