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

      # Under systemd, the service is called mdmonitor
      if ($operatingsystem == 'Ubuntu' and versioncmp($operatingsystemrelease, '16.04') < 0) or ($operatingsystem == 'Debian' and versioncmp($operatingsystemrelease, '9') < 0) {
        $service_name = 'mdadm'
      } else {
        $service_name = 'mdmonitor'
      }

      $service_ensure = 'running'
      $service_manage = true

      # Older mdadm packages don't have a service status
      if versioncmp($operatingsystemrelease, '12.04') < 0 {
        $service_hasstatus = false
      } else {
        $service_hasstatus = true
      }

      $include_cron = true
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
