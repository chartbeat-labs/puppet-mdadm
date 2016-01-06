Puppet::Type.newtype(:mdadm) do

  desc <<-EOT
    A resource type for managing md raid arrays.

    Example:

        mdadm { '/dev/md0' :
          ensure => 'create',
          devices => ['/dev/sdb', '/dev/sdc'],
          level => 0,
        }

        mdadm { '/dev/md1' :
          ensure => 'assemble',
          devices => ['/dev/sdd', '/dev/sde'],
          level => 0,
        }

        mdadm { '/dev/md2' :
          ensure => 'stop',
          devices => ['/dev/sdf', '/dev/sdg'],
          level => 0,
        }
  EOT

  ensurable do
    newvalue(:created) do
      provider.create
    end

    newvalue(:assembled) do
      provider.assemble
    end

    newvalue(:absent) do
      provider.stop
    end

    aliasvalue :stopped, :absent

    defaultto :created

    def retrieve
      result = provider.exists?

      if result
        case resource[:ensure]
        when :assembled
          return :assembled
        else
          return :created
        end
      else
        return :absent
      end
    end

  end

  newparam(:name, :namevar => true) do
    desc 'The raid device used as the identity of the resource.'
  end

  newparam(:devices) do
    desc 'An array of underlying devices for the raid'
    validate do |value|
      raise(Puppet::Error, "Devices must be an array") unless value.is_a?(Array)
    end
  end

  newparam(:level) do
    desc 'The raid level, 0,1,4,5,6 linear, multipath and synonyms.'
  end

  newparam(:active_devices) do
    desc <<-EOT
      An optional value used to specify the number of devices that are active.
      Cannot be more than the number of devices. Defaults to all devices.
    EOT

    defaultto do
      resource[:devices].size if resource[:devices]
    end
  end

  newparam(:spare_devices) do
    desc 'An optional value used to specify the number of spare devices.'
  end

  newparam(:chunk) do
    desc 'Optionally specify the chunksize in kibibytes.'
  end

  newparam(:parity) do
    desc 'The raid parity. Only applicable to raid5/6/10'
    newvalues('left-symmetric', 'right-symmetric', 'left-asymmetric',
              'right-asymmetric', 'f2', 'n2', 'o2')
  end

  newparam(:bitmap) do
    desc 'Create a bitmap for the array with the given filename'
  end

  newparam(:metadata) do
    desc <<-EOT
      Default style of RAID metadata (superblock) to be used. The default is
      0.9. There seems to be an issue with the 1.2 on newer mdadm/kernels with
      the --name parameter getting set.

      See http://ubuntuforums.org/showthread.php?t=1764861 for more info
    EOT
    newvalues('0.9', '1.0', '1.1', '1.2')
    defaultto '0.9'
  end

  newparam(:generate_conf, :boolean => true) do
    desc 'Whether to generate the mdadm.conf file'
    newvalues(:true, :false)
    defaultto :true
  end

  newparam(:update_initramfs, :boolean => true) do
    desc <<-EOT
      Whether to update the ram filesystem with the md device. Only makes sense
      if you are also generating the mdadm.conf.

      This can work around a problem with updated kernels not seeing the md
      device and assigning a random device number.

      See http://ubuntuforums.org/showthread.php?t=1764861 for more info
    EOT
    newvalues(:true, :false)
    defaultto :true
  end

  newparam(:force, :boolean => true) do
    desc <<-EOT
      Whether to force the action. Useful for when the underlying devices had
      previously been created on an array. Can be destructive if the underlying
      devices were part of different arrays. Use with caution.
    EOT
    newvalues(:true, :false)
    defaultto :false
  end

  validate do
    unless self[:devices] and self[:level]
      raise(Puppet::Error, "Both devices and level are required attributes")
    end

    if self[:parity] and not [5, '5', 'raid5', '6', 6, 'raid6', 10, '10', 'raid10'].include?(self[:level])
      raise(Puppet::Error, "Parity can only be set on raid5/6/10")
    end
  end

  autorequire(:package) do
    ['mdadm']
  end
end
