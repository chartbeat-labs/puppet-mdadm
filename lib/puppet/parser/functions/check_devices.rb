module Puppet::Parser::Functions
  newfunction(:check_devices, :type => :rvalue, :doc => "\
    Check that devices exist and are block devices.

    Example: check_devices(['/dev/sdb', '/dev/sdc'], $::blockdevices)") do |args|

    raise(Puppet::ParseError, "check_devices(): Wrong number of arguments " +
      "given (#{args.size} for 2)") if args.size != 2

    # Strip /dev/ from devices
    devices = args[0].map { |d| d.split('/')[2] }

    # Fact comes as a comma separated string
    blockdevs = args[1].split(',')

    [devices, blockdevs].each do |device|
      unless [Array].include?(device.class)
        raise(Puppet::ParseError, "check_devices(): Requires and Array (given (#{device.class}))")
      end
    end

    return (devices - blockdevs).empty?
  end
end
