# == Class mdadm::service
#
# This class is meant to be called from mdadm
# It ensure the service is running
#
class mdadm::service {

  if ($::mdadm::service_manage) {
    service { $::mdadm::service_name:
      ensure     => $::mdadm::service_ensure,
      enable     => true,
      hasstatus  => $::mdadm::service_hasstatus,
      hasrestart => true,
    }
  }
}
