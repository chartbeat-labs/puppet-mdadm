Puppet Mdadm Module
===================

Puppet module for managing md raid arrays.

[![Build Status](https://travis-ci.org/chartbeat-labs/puppet-mdadm.png)](https://travis-ci.org/chartbeat-labs/puppet-mdadm)

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

#### Note on parameters with RedHat OSFamily:
The following parameters do not work with RedHat based systems:
```puppet
mdadm { $name :
    ...
    generate_conf    => $generate_conf,
    update_initramfs => $update_initramfs,
  }
```

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

### Metadata

You can specify the metadata superblock type by passing the metadata parameter.
See mdadm(8) for more info. The default is v0.9. It only makes sense for the create
operation.

```puppet
mdadm { '/dev/md1' :
  ensure    => 'created',
  devices   => ['/dev/sdb', '/dev/sdc'],
  level     => 0,
  metadata  => '0.9',
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

### Updating ramfs

By default, the mdadm type will update initrd with the update-initramfs -u command.
The reason for this is to allow devices created by md to be seen by the kernel at boot
to allow for devices to be mounted as the root device if desired. It also seems to fix
an issue seen in more recent kernels/mdadm. What happens is you create an md device of
say /dev/md1, you don't update initrd, the kernel on boot sees that certain devices
are members of an array but doesn't know the array name (/dev/md1) and so it assigns
an arbitrary name, /dev/md126, and starts the array. This can cause entries in /etc/fstab
to not be found, causing mount on boot problems.

The solution is to just update initrd with the devices created by md, so this option
defaults to true.

You can disable by passing update_initramfs => false.

```puppet
mdadm { '/dev/md1' :
  ensure           => 'assembled',
  devices          => ['/dev/sdb', '/dev/sdc'],
  level            => 0,
  update_initramfs => false,
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
```

### Functions

#### check_devices()

This function can be used to check whether a given device exists. You pass it an
array of devices, it expects them to start with '/dev/' and a string of comma
separated devices on the system, specifically the $blockdevices fact. Returns true
if *all* devices exist and false otherwise.

```puppet
$result = check_devices(['/dev/sdb', '/dev/sdc'], $::blockdevices)

if $result {
  ...do something
}
```

This is useful if you are booting a system but your blockdevices aren't available
at boot and you still want to have the mdadm::array configured in puppet. The mdadm
type will error out if the devices aren't available so this function allows you to
pass on applying that resource until the blockdevices become available.

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
