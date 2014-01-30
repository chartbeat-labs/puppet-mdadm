module Puppet::Parser::Functions
  newfunction(:check_devices, :type => :rvalue, :doc => "\
    Check that devices exist and are block devices.

    Example: check_devices(['/dev/sdb', '/dev/sdc'])") do |args|

    raise(Puppet::ParseError, "check_devices(): Wrong number of arguments " +
      "given (#{args.size} for 1)") if args.size < 1 or args.size > 1

    devices = args[0]
    klass = devices.class

    unless [Array].include?(klass)
      raise(Puppet::ParseError, "check_devices(): Requires an Array (given (#{klass}))")
    end

    result = true
    devices.each do |device|
      next if File.blockdev?(device)
      result = false
    end

    return result
  end
end
