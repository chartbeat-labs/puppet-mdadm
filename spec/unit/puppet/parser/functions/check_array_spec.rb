require 'spec_helper'

describe 'check_devices' do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  describe 'argument handling' do
    it 'fails with no arguments' do
      lambda { scope.function_check_devices([]) }.should raise_error(Puppet::ParseError)
    end

    it 'fails without an array' do
      lambda { scope.function_check_devices(['foo']) }.should raise_error
    end

    it 'requires an array' do
      lambda { scope.function_check_devices([['foo']]) }.should_not raise_error
    end
  end

  describe 'device handling' do
    it 'should return true' do
      File.stubs(:blockdev?).returns(true)
      scope.function_check_devices([['/dev/sdb', '/dev/sdc']]).should == true
    end

    it 'should return false' do
      File.stubs(:blockdev?).returns(false)
      scope.function_check_devices([['/dev/sdb', '/dev/sdc']]).should == false
    end
  end
end
