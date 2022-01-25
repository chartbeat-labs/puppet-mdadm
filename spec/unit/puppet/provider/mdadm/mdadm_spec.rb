require 'spec_helper'
require 'puppet'

provider_class = Puppet::Type.type(:mdadm).provider(:mdadm)

$count = 0
describe provider_class do
  before :each do
    # Create a mock resource
    @resource = double('resource')
    allow(@resource).to receive(:name).and_return('/dev/md1')
    allow(@resource).to receive(:[]).with(:devices).and_return(['/dev/sdb', '/dev/sdc'])
    allow(@resource).to receive(:[]).with(:level).and_return('0')
    allow(@resource).to receive(:[]).with(:metadata).and_return('0.9')
    allow(@resource).to receive(:[]).with(:active_devices).and_return(nil)
    allow(@resource).to receive(:[]).with(:spare_devices).and_return(nil)
    allow(@resource).to receive(:[]).with(:parity).and_return(nil)
    allow(@resource).to receive(:[]).with(:chunk).and_return(nil)
    allow(@resource).to receive(:[]).with(:force).and_return(false)
    allow(@resource).to receive(:[]).with(:generate_conf).and_return(true)
    allow(@resource).to receive(:[]).with(:update_initramfs).and_return(true)

    @provider = provider_class.new(@resource)
    allow(@provider.class).to receive(:command).with(:mdadm_cmd).and_return('/sbin/mdadm')
    allow(@provider.class).to receive(:command).with(:mkconf).and_return('/usr/share/mdadm/mkconf')
    allow(@provider.class).to receive(:command).with(:yes).and_return('/usr/bin/yes')
    allow(@provider.class).to receive(:command).with(:update_initramfs).and_return('/usr/sbin/update_initramfs')
  end

  describe '#create' do
    it "should execute the correct mdadm command" do
      expect(@provider).to receive(:execute).with('/sbin/mdadm --create -e 0.9 /dev/md1 --level=0 --raid-devices=2 /dev/sdb /dev/sdc')
      expect(@provider).to receive(:make_conf)
      expect(@provider).to receive(:update_initramfs)
      @provider.create
    end

    it "should include the supplied parameters" do
      allow(@resource).to receive(:[]).with(:devices).and_return(['/dev/sdb', '/dev/sdc', '/dev/sdd', '/dev/sde'])
      allow(@resource).to receive(:[]).with(:active_devices).and_return('3')
      allow(@resource).to receive(:[]).with(:spare_devices).and_return('1')
      allow(@resource).to receive(:[]).with(:metadata).and_return('1.2')
      allow(@resource).to receive(:[]).with(:parity).and_return('right-symmetric')
      allow(@resource).to receive(:[]).with(:chunk).and_return('512')
      allow(@resource).to receive(:[]).with(:force).and_return(true)
      allow(@resource).to receive(:[]).with(:generate_conf).and_return(false)
      allow(@resource).to receive(:[]).with(:update_initramfs).and_return(false)

      expect(@provider).to receive(:execute).with('/usr/bin/yes | /sbin/mdadm --create -e 1.2 /dev/md1 --level=0 --raid-devices=3 --spare-devices=1 --parity=right-symmetric --chunk=512 /dev/sdb /dev/sdc /dev/sdd /dev/sde')
      @provider.create
    end
  end

  describe '#assemble' do
    it 'should execute the correct mdadm command' do
      expect(@provider).to receive(:execute).with(['/sbin/mdadm', '--assemble', '/dev/md1',
                                           ['/dev/sdb', '/dev/sdc']])
      expect(@provider).to receive(:make_conf)
      expect(@provider).to receive(:update_initramfs)
      @provider.assemble
    end

    it 'should include the supplied parameters' do
      allow(@resource).to receive(:[]).with(:generate_conf).and_return(false)
      allow(@resource).to receive(:[]).with(:update_initramfs).and_return(false)
      expect(@provider).to receive(:execute).with(['/sbin/mdadm', '--assemble', '/dev/md1',
                                        ['/dev/sdb', '/dev/sdc']])
      @provider.assemble
    end
  end

  describe '#stop' do
    it 'should execute the correct mdadm command' do
      expect(@provider).to receive(:execute).with(['/sbin/mdadm', '--misc', '--stop', '/dev/md1'])
      expect(@provider).to receive(:make_conf)
      expect(@provider).to receive(:update_initramfs)
      @provider.stop
    end

    it 'should include the supplied parameters' do
      expect(@resource).to receive(:[]).with(:generate_conf).and_return(false)
      expect(@resource).to receive(:[]).with(:update_initramfs).and_return(false)
      expect(@provider).to receive(:execute).with(['/sbin/mdadm', '--misc', '--stop', '/dev/md1'])
      @provider.stop
    end
  end

  describe '#exists?' do
    it 'should return true if array exists' do
      allow_message_expectations_on_nil
      expect(@provider).to receive(:execute).with(['/sbin/mdadm', '--detail', '--test', '/dev/md1']).and_return(0)
      allow($CHILD_STATUS).to receive(:exitstatus).and_return(0)
      expect(@provider.exists?).to eq(true)
    end

    it 'should return false if array does not exist' do
      allow_message_expectations_on_nil
      allow(@provider).to receive(:execute).and_raise(Puppet::ExecutionFailure, 'mdadm array /dev/md1 not found')
      allow($CHILD_STATUS).to receive(:exitstatus).and_return(4)
      expect(@provider.exists?).to eq(false)
    end

    it 'should raise error if command fails' do
      allow_message_expectations_on_nil
      allow(@provider).to receive(:execute).and_raise(Puppet::ExecutionFailure, 'Command not found')
      allow($CHILD_STATUS).to receive(:exitstatus).and_return(127)
      expect { @provider.exists?}.to raise_error(Puppet::ExecutionFailure, /Command not found/)
    end
  end
end
