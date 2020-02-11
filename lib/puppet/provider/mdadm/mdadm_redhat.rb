require 'puppet'

Puppet::Type.type(:mdadm).provide(:mdadm) do
  desc "Manage Md raid devices"
  confine :osfamily => [:redhat]

  commands  :mdadm_cmd => 'mdadm',
            :yes => 'yes'

  def create
    cmd = [command(:mdadm_cmd)]
    cmd << "--create"
    cmd << "-e #{resource[:metadata]}"
    cmd << resource.name
    cmd << "--level=#{resource[:level]}"
    cmd << "--raid-devices=#{resource[:active_devices] || resource[:devices].size}"
    cmd << "--spare-devices=#{resource[:spare_devices]}" if resource[:spare_devices]
    cmd << "--parity=#{resource[:parity]}" if resource[:parity]
    cmd << "--chunk=#{resource[:chunk]}" if resource[:chunk]
    cmd << resource[:devices]

    if resource[:force]
      cmd.unshift(command(:yes), "|")
    end

    execute(cmd.join(" "))
  end

  def assemble
    cmd = [command(:mdadm_cmd)]
    cmd << "--assemble"
    cmd << resource.name
    cmd << resource[:devices]
    execute(cmd)
  end

  def stop
    cmd = [command(:mdadm_cmd)]
    cmd << "--misc"
    cmd << "--stop"
    cmd << resource.name
    execute(cmd)
  end

  def exists?
    device_not_found = 4
    begin
      execute([command(:mdadm_cmd), "--detail", "--test", resource.name])
      debug "Device #{resource.name} found"
      return ($CHILD_STATUS.exitstatus == 0)
    rescue Puppet::ExecutionFailure
      if ($CHILD_STATUS.exitstatus == device_not_found)
        debug "Device #{resource.name} not found"
        return false
      else
        raise
      end
    end
  end
end
