require 'spec_helper'

describe 'check_devices' do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  describe 'argument handling' do
    it 'fails with no arguments' do
      expect { scope.function_check_devices([]) }.to raise_error(Puppet::ParseError)
    end

    it 'fails without an array' do
      expect { scope.function_check_devices(['foo']) }.to raise_error(Puppet::ParseError)
    end

    it 'requires an array as first arg and a string as second' do
      expect { scope.function_check_devices([['foo'], 'bar']) }.not_to raise_error
    end
  end

  describe 'device handling' do
    it 'should return true' do
      expect(scope.function_check_devices([['/dev/sdb', '/dev/sdc'], 'sda,sdb,sdc'])).to be(true)
    end

    it 'should return false' do
      expect(scope.function_check_devices([['/dev/sdb', '/dev/sdc'], 'sda'])).to be(false)
    end

    it 'should return false on garbage data' do
      expect(scope.function_check_devices([['foo', 'bar/baz'] , ''])).to be(false)
    end
  end
end
