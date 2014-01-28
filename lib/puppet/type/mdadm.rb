require 'puppet/parameter/boolean'

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
      Cannot be more than the number of devices. Defaults to all devices.'
    EOT

    defaultto do
      resource[:devices].size if resource[:devices]
    end
  end

  newparam(:spare_devices) do
    desc 'An optional value used to specify the number of spare devices.'
  end

  newparam(:chunk) do
    desc 'Optionally specify the chunksize in kibibytes'
  end

  newparam(:parity) do
    desc 'The raid parity. Only applicable to raid5/6'
    newvalues('left-symmetric', 'right-symmetric', 'left-asymmetric',
              'right-asymmetric')
  end

  newparam(:bitmap) do
    desc 'Create a bitmap for the array with the given filename'
  end

  newparam(:generate_conf, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc 'Whether to generate the mdadm.conf file'
    defaultto :true
  end

  newparam(:force, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc <<-EOT
      Whether to force the action. Useful for when the underlying devices had
      previously been created on an array. Can be destructive if the underlying
      devices were part of different arrays. Use with caution.
    EOT
    defaultto :false
  end

  validate do
    unless self[:devices] and self[:level]
      raise(Puppet::Error, "Both devices and level are required attributes")
    end

    if self[:parity] and not [5, '5', 'raid5', '6', 6, 'raid6'].include?(self[:level])
      raise(Puppet::Error, "Parity can only be set on raid5/6")
    end
  end

  autorequire(:package) do
    ['mdadm']
  end
end
