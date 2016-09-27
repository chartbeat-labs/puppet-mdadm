# == Class mdadm::params
#
# This class is meant to be called from mdadm
# It sets variables according to platform
#
class mdadm::params {
  case $::osfamily {
    'Debian': {
      $package_name = 'mdadm'
      $package_ensure = 'present'
      $service_name = 'mdadm'
      $service_ensure = 'running'
      $service_manage = true
      # Older mdadm packages don't have a service status
      if versioncmp($lsbdistrelease, '12') < 0 {
        $service_hasstatus = false
      } else {
        $service_hasstatus = true
      }
      $include_cron = true
      $cron_name = '/etc/cron.d/mdadm'
    }
    'RedHat': {
      $package_name = 'mdadm'
      $package_ensure = 'present'
      $service_name = 'mdmonitor'
      $service_ensure = 'stopped'
      $service_manage = false
      $service_hasstatus = true
      $include_cron = true
      $cron_name = '/etc/cron.d/raid-check'
    }
    default: {
      fail(" osfamily: ${::osfamily}, operatingsystem: ${::operatingsystem} not supported")
    }
  }
}
