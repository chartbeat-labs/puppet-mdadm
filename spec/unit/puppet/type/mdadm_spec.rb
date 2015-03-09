#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:mdadm) do

  before :each do
    Puppet::Type.type(:mdadm).stubs(:defaultprovider).returns(providerclass)
  end

  let(:providerclass) do
    described_class.provide(:fake_mdadm_provider) do
      attr_accessor :property_hash
      def create; end
      def assemble; end
      def stop; end
      def exists?
        get(:ensure) != :absent
      end
      mk_resource_methods
    end
  end

  let(:provider) do
    providerclass.new(:name => '/dev/md1')
  end

  let(:resource) do
    described_class.new(:name => '/dev/md1',
                        :devices => ['/dev/sdb', '/dev/sdc'],
                        :level => 0,
                        :provider => provider)
  end

  let(:ensureprop) do
    resource.property(:ensure)
  end

  properties = [ :ensure ]

  properties.each do |property|
    it "should have a #{property} property" do
      expect(described_class.attrclass(property).ancestors).to be_include(Puppet::Property)
    end
  end

  parameters = [ :devices, :level, :active_devices, :spare_devices, :parity,
                 :chunk, :force, :generate_conf, :update_initramfs]

  parameters.each do |parameter|
    it "should have a #{parameter} parameter" do
      expect(described_class.attrclass(parameter).ancestors).to be_include(Puppet::Parameter)
    end
  end

  describe 'default resource with required params' do
    it 'should have a valid name parameter' do
      expect(resource[:name]).to eq('/dev/md1')
    end

    it 'should have :ensure set to :created' do
      expect(resource[:ensure]).to eq(:created)
    end

    it 'should have devices set' do
      expect(resource[:devices]).to eq(['/dev/sdb', '/dev/sdc'])
    end

    it 'should have the raid level set' do
      expect(resource[:level]).to eq(0)
    end

    it 'should have the active_devices derived' do
      expect(resource[:active_devices]).to eq(2)
    end

    defaults = { :spare_devices => nil,
                 :chunk => nil,
                 :parity => nil,
                 :bitmap => nil,
                 :generate_conf => :true,
                 :update_initramfs => :true,
                 :force => :false,
    }

    defaults.each_pair do |param, value|
      it "should have #{param} parameter set to #{value}" do
        expect(resource[param]).to eq(value)
      end
    end
  end

  describe 'resource with all valid params' do
    let(:resource) do
      described_class.new(:name => '/dev/md1',
                          :devices => ['/dev/sdb', '/dev/sdc', '/dev/sdd', '/dev/sde'],
                          :level => 5,
                          :ensure => :created,
                          :active_devices => 3,
                          :spare_devices => 1,
                          :parity => 'right-symmetric',
                          :bitmap => '/tmp/bitmap',
                          :generate_conf => :false,
                          :update_initramfs => :false,
                          :force => :true,
                          :provider => provider)

    end

    it { expect(resource[:devices]).to eq(['/dev/sdb', '/dev/sdc', '/dev/sdd', '/dev/sde']) }
    it { expect(resource[:level]).to eq(5) }
    it { expect(resource[:ensure]).to eq(:created) }
    it { expect(resource[:active_devices]).to eq(3) }
    it { expect(resource[:spare_devices]).to eq(1) }
    it { expect(resource[:parity]).to eq(:'right-symmetric') }
    it { expect(resource[:bitmap]).to eq('/tmp/bitmap') }
    it { expect(resource[:generate_conf]).to eq(:false) }
    it { expect(resource[:update_initramfs]).to eq(:false) }
    it { expect(resource[:force]).to eq(:true) }
  end

  describe 'resource with invalid ensure' do
    let(:resource) do
      described_class.new(:name => '/dev/md1',
                          :devices => ['/dev/sdb', '/dev/sdc'],
                          :level => 0,
                          :ensure => :present,
                          :provider => provider)

    end
    it { expect { resource }.to raise_error(Puppet::Error,
        /Invalid value :present. Valid values are created, assembled, absent./)
    }
  end

  invalid_params = [ :generate_conf, :update_initramfs, :force ]

  invalid_params.each do |param|
    describe "resource with invalid #{param}" do
      let(:resource) do
        described_class.new(:name => '/dev/md1',
                            :devices => ['/dev/sdb', '/dev/sdc'],
                            :level => 0,
                            param => 'foo',
                            :provider => provider)
      end
      it { expect { resource }.to raise_error(Puppet::Error) }
    end
  end

  describe 'resource without required params' do
    let(:resource) do
      described_class.new(:name => '/dev/md1')
    end
    it { expect { resource }.to raise_error(Puppet::Error, /Both devices and level are required attributes/ ) }
  end

  describe 'resource with mismatched :level and :parity' do
    let(:resource) do
      described_class.new(:name => '/dev/md1',
                          :devices => ['/dev/sdb', '/dev/sdc'],
                          :level => 1,
                          :parity => 'left-asymmetric',
                          :provider => provider)
    end
    it { expect { resource }.to raise_error(Puppet::Error, /Parity can only be set on raid5\/6/) }
  end

  describe 'resource with invalid parity' do
    let(:resource) do
      described_class.new(:name => '/dev/md1',
                          :devices => ['/dev/sdb', '/dev/sdc'],
                          :level => 5,
                          :parity => 'foo',
                          :provider => provider)
    end
    it { expect { resource }.to raise_error(Puppet::Error,
        /Invalid value "foo". Valid values are left-symmetric, right-symmetric, left-asymmetric, right-asymmetric/ ) }
  end

  describe 'when changing the ensure' do
    it 'should be in sync if it is :absent and should be :absent' do
      ensureprop.should = :absent
      expect(ensureprop.safe_insync?(:absent)).to eq(true)
    end

    it 'should be out of sync if it is :absent and should be :created' do
      ensureprop.should = :created
      expect(ensureprop.safe_insync?(:absent)).to eq(false)
    end

    it 'should be out of sync if it is :absent and should be :assembled' do
      ensureprop.should = :assembled
      expect(ensureprop.safe_insync?(:absent)).to eq(false)
    end

    it 'should be in sync if it should be :stopped and should be :absent' do
      ensureprop.should = :stopped
      expect(ensureprop.safe_insync?(:absent)).to eq(true)
    end
  end

  describe 'when running the type it should autorequire the mdadm package' do
    before :each do
      @catalog = Puppet::Resource::Catalog.new
      @mdadm_package = Puppet::Type.type(:package).new(:name => 'mdadm')
      @catalog.add_resource(@mdadm_package)
    end

    it 'should require package mdadm' do
      @resource = described_class.new(:name => '/dev/md1', :devices => ['/dev/sdb'], :level => 0, :provider => provider)
      @catalog.add_resource(@resource)
      req = @resource.autorequire
      expect(req.size).to eq(1)
    end
  end
end
