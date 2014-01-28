# == Class mdadm::install
# This class is meant to be called from mdadm
# Installs the package.
#
class mdadm::install {

  package { $::mdadm::package_name :
    ensure => $::mdadm::package_ensure,
  }
}
