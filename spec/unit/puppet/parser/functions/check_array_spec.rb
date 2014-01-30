require 'spec_helper'

describe 'check_devices' do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  describe 'argument handling' do
    it 'fails with no arguments' do
      lambda { scope.function_check_devices([]) }.should raise_error(Puppet::ParseError)
    end

    it 'fails without an array' do
      lambda { scope.function_check_devices(['foo']) }.should raise_error(Puppet::ParseError)
    end

    it 'requires an array as first arg and a string as second' do
      lambda { scope.function_check_devices([['foo'], 'bar']) }.should_not raise_error
    end
  end

  describe 'device handling' do
    it 'should return true' do
      scope.function_check_devices([['/dev/sdb', '/dev/sdc'], 'sda,sdb,sdc']).should == true
    end

    it 'should return false' do
      scope.function_check_devices([['/dev/sdb', '/dev/sdc'], 'sda']).should == false
    end

    it 'should return false on garbage data' do
      scope.function_check_devices([['foo', 'bar/baz'] , '']).should == false
    end
  end
end
