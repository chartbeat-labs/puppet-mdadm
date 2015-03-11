require 'spec_helper'
require 'puppet'

provider_class = Puppet::Type.type(:mdadm).provider(:mdadm)

$count = 0
describe provider_class do
  before :each do
    # Create a mock resource
    @resource = stub('resource')
    @resource.stubs(:name).returns('/dev/md1')
    @resource.stubs(:[]).with(:devices).returns(['/dev/sdb', '/dev/sdc'])
    @resource.stubs(:[]).with(:level).returns(0)
    @resource.stubs(:[]).with(:metadata).returns('0.9')
    @resource.stubs(:[]).with(:active_devices).returns(nil)
    @resource.stubs(:[]).with(:spare_devices).returns(nil)
    @resource.stubs(:[]).with(:parity).returns(nil)
    @resource.stubs(:[]).with(:chunk).returns(nil)
    @resource.stubs(:[]).with(:force).returns(false)
    @resource.stubs(:[]).with(:generate_conf).returns(true)
    @resource.stubs(:[]).with(:update_initramfs).returns(true)

    @provider = provider_class.new(@resource)
    @provider.class.stubs(:command).with(:mdadm_cmd).returns('/sbin/mdadm')
    @provider.class.stubs(:command).with(:mkconf).returns('/usr/share/mdadm/mkconf')
    @provider.class.stubs(:command).with(:yes).returns('/usr/bin/yes')
    @provider.class.stubs(:command).with(:update_initramfs).returns('/usr/sbin/update_initramfs')
  end

  describe '#create' do
    it "should execute the correct mdadm command" do
      @provider.expects(:execute).with('/sbin/mdadm --create -e 0.9 /dev/md1 --level=0 --raid-devices=2 /dev/sdb /dev/sdc')
      @provider.expects(:make_conf)
      @provider.expects(:update_initramfs)
      @provider.create
    end

    it "should include the supplied parameters" do
      @resource.stubs(:[]).with(:devices).returns(['/dev/sdb', '/dev/sdc', '/dev/sdd', '/dev/sde'])
      @resource.stubs(:[]).with(:active_devices).returns(3)
      @resource.stubs(:[]).with(:spare_devices).returns(1)
      @resource.stubs(:[]).with(:metadata).returns('1.2')
      @resource.stubs(:[]).with(:parity).returns('right-symmetric')
      @resource.stubs(:[]).with(:chunk).returns('512')
      @resource.stubs(:[]).with(:force).returns(true)
      @resource.stubs(:[]).with(:generate_conf).returns(false)
      @resource.stubs(:[]).with(:update_initramfs).returns(false)
      @provider.expects(:execute).with('/usr/bin/yes | /sbin/mdadm --create -e 1.2 /dev/md1 --level=0 --raid-devices=3 --spare-devices=1 --parity=right-symmetric --chunk=512 /dev/sdb /dev/sdc /dev/sdd /dev/sde')
      @provider.create
    end
  end

  describe '#assemble' do
    it 'should execute the correct mdadm command' do
      @provider.expects(:execute).with(['/sbin/mdadm', '--assemble', '/dev/md1',
                                        ['/dev/sdb', '/dev/sdc']])
      @provider.expects(:make_conf)
      @provider.expects(:update_initramfs)
      @provider.assemble
    end

    it 'should include the supplied parameters' do
      @resource.stubs(:[]).with(:generate_conf).returns(false)
      @resource.stubs(:[]).with(:update_initramfs).returns(false)
      @provider.expects(:execute).with(['/sbin/mdadm', '--assemble', '/dev/md1',
                                        ['/dev/sdb', '/dev/sdc']])
      @provider.assemble
    end
  end

  describe '#stop' do
    it 'should execute the correct mdadm command' do
      @provider.expects(:execute).with(['/sbin/mdadm', '--misc', '--stop', '/dev/md1'])
      @provider.expects(:make_conf)
      @provider.expects(:update_initramfs)
      @provider.stop
    end

    it 'should include the supplied parameters' do
      @resource.stubs(:[]).with(:generate_conf).returns(false)
      @resource.stubs(:[]).with(:update_initramfs).returns(false)
      @provider.expects(:execute).with(['/sbin/mdadm', '--misc', '--stop', '/dev/md1'])
      @provider.stop
    end
  end

  describe '#exists?' do
    it 'should return true if array exists' do
      @provider.expects(:execute).with(['/sbin/mdadm', '--detail', '--test', '/dev/md1']).returns(0)
      expect(@provider.exists?).to eq(true)
    end

    it 'should return false if array does not exist' do
      @provider.stubs(:execute).raises(Puppet::ExecutionFailure, 'mdadm array /dev/md1 not found')
      $CHILD_STATUS.stubs(:exitstatus).returns(4)
      expect(@provider.exists?).to eq(false)
    end

    it 'should raise error if command fails' do
      @provider.stubs(:execute).raises(Puppet::ExecutionFailure, 'Command not found')
      $CHILD_STATUS.stubs(:exitstatus).returns(127)
      expect { @provider.exists?}.to raise_error(Puppet::ExecutionFailure, /Command not found/)
    end
  end
end
