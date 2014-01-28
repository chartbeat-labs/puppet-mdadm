Puppet Mdadm Module
===================

Puppet module for managing md raid arrays.

[![Build Status](https://travis-ci.org/butlern/puppet-mdadm.png)](https://travis-ci.org/butlern/puppet-mdadm)

Usage
-----

Include with default parameters:

```puppet
include mdadm
```

Include with the singleton pattern:

```puppet
class { '::mdadm' : }
```

If you don't want the mdadm monitor running you can either ensure that it is
stopped:

```puppet
class { '::mdadm' :
  service_ensure => 'stopped',
}
```

or you can just leave the service unmanaged and stop it through some other means:

```puppet
class { '::mdadm' :
  service_managed => false,
}
```

### Md Arrays

The custom type *mdadm* is available for creating, assembling or stopping raid
arrays. The name or title should be the raid device name. Required values are
an array of underlying devices, and the raid level. All other parameters are
optional.

The available parameters are the following:

### Parameters
*See puppet doc*

### Creating an array

From scratch, you can create a striped array of two underlying devices with the
following:

```puppet
mdadm { '/dev/md1' :
  ensure    => 'created',
  devices   => ['/dev/sdb', '/dev/sdc'],
  level     => 0,
}
```

If one or both of the two devices were previously members of an array, (mdadm
discovered superblock information on them), then the above would fail.

If you are sure that you want to recreate the array, you can force the creation
of it by passing force => true.

```puppet
mdadm { '/dev/md1' :
  ensure    => 'created',
  devices   => ['/dev/sdb', '/dev/sdc'],
  level     => 0,
  force     => true,
}
```

If all underlying devices were members of the same array, this is not a destructive
action. However, if they were members of different arrays you *WILL LOSE DATA*.

A more conservative approach would be to attempt to assemble the array first. This
way if they were previously members of the same array, then the assembly will
proceed, otherwise it will fail.

### Assembling an array

```puppet
mdadm { '/dev/md1' :
  ensure    => 'assembled',
  devices   => ['/dev/sdb', '/dev/sdc'],
  level     => 0,
}
```

### Stopping an array

This will stop the array but is not destructive. You can reassemble the array later
with the same devices.

```puppet
mdadm { '/dev/md1' :
  ensure    => 'stopped', # absent is a synomym
  devices   => ['/dev/sdb', '/dev/sdc'],
  level     => 0,
}
```

### Generating the conf

By default, the mdadm type will generate the mdadm.conf file. This is so that the
device can be mounted at boot. If you don't want this to happen or you wish to
manage the file yourself, you can pass generate_conf => false.

```puppet
mdadm { '/dev/md1' :
  ensure        => 'assembled',
  devices       => ['/dev/sdb', '/dev/sdc'],
  level         => 0,
  generate_conf => false,
}
```

### Defined Type mdadm::array

Because the mdadm provider relies upon the mdadm command to be present on the system
and while the mdadm type autorequires the mdadm package, there is no way to ensure
that the package gets installed.

The mdadm::array is a simple wrapper that includes the mdadm class to ensure the
mdadm package is installed. It doesn't do any parameter validation, it just passes
the parameters to the mdadm type.

So if you don't want to have to do this:

```puppet
# Ensure mdadm is present
include mdadm

# Create array
mdadm { '/dev/md1':
  ensure  => 'created',
  devices => ['/dev/sdb', '/dev/sdc'],
  level   => 0,
}
```

Instead you can just use the wrapper:

```puppet
mdadm::array { '/dev/md1':
  ensure  => 'created',
  devices => ['/dev/sdb', '/dev/sdc'],
  level   => 0,
}

Limitations
-----------

### Resizing Raid Arrays

The mdadm type is pretty basic, it will not attempt to manage a device once it
is created other than to stop the array. You cannot add spares to the array by
appending additional devices to the devices parameter. Nor will it remove
devices from a raid array when they are removed from the devices parameter.

### Filesystem Creation

Currently the mdadm type does not create a filesystem on a raid array. If you
are looking to setup a raided mountpoint using this type and the puppet mount type
you will need to create the filesystem for any new arrays. Assembled arrays should
already have a filesystem.

If you want something a bit more robust than your own exec, check out the filesystem
type in the excellent PuppetLabs [LVM module](https://github.com/puppetlabs/puppetlabs-lvm)

For example, this would be a complete setup:

```puppet
mdadm { '/dev/md1' :
  ensure  => 'created',
  devices => ['/dev/sdb', '/dev/sdc'],
  level   => 0,
  before  => Filesystem['/dev/md1']
}

filesystem { '/dev/md1' :
  ensure  => 'present',
  fs_type => 'ext4',
  before  => Mount['/mnt']
}

mount { '/mnt' :
  ensure  => 'mounted',
  atboot  => true,
  device  => '/dev/md1',
  fstype  => 'ext4',
  options => 'defaults',
}
```

## License

See [LICENSE](LICENSE) file.
