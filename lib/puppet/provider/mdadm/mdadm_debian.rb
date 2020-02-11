require 'puppet'

Puppet::Type.type(:mdadm).provide(:mdadm) do
  desc "Manage Md raid devices"
  confine :osfamily => [:debian]
  
  commands  :mdadm_cmd => 'mdadm',
            :mkconf => '/usr/share/mdadm/mkconf',
            :yes => 'yes',
            :update_initramfs => 'update-initramfs'

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
    make_conf if resource[:generate_conf]
    update_initramfs if resource[:update_initramfs]
  end

  def assemble
    cmd = [command(:mdadm_cmd)]
    cmd << "--assemble"
    cmd << resource.name
    cmd << resource[:devices]
    execute(cmd)
    make_conf if resource[:generate_conf]
    update_initramfs if resource[:update_initramfs]
  end

  def stop
    cmd = [command(:mdadm_cmd)]
    cmd << "--misc"
    cmd << "--stop"
    cmd << resource.name
    execute(cmd)
    make_conf if resource[:generate_conf]
    update_initramfs if resource[:update_initramfs]
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

  private

  def make_conf
    execute([command(:mkconf), "force-generate"])
  end

  def update_initramfs
    execute([command(:update_initramfs), '-u'])
  end
end
