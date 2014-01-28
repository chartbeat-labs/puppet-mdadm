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
      described_class.attrclass(property).ancestors.should be_include(Puppet::Property)
    end
  end

  parameters = [ :devices, :level, :active_devices, :spare_devices, :parity,
                 :chunk, :force, :generate_conf]

  parameters.each do |parameter|
    it "should have a #{parameter} parameter" do
      described_class.attrclass(parameter).ancestors.should be_include(Puppet::Parameter)
    end
  end

  describe 'default resource with required params' do
    it 'should have a valid name parameter' do
      resource[:name].should == '/dev/md1'
    end

    it 'should have :ensure set to :created' do
      resource[:ensure].should == :created
    end

    it 'should have devices set' do
      resource[:devices].should == ['/dev/sdb', '/dev/sdc']
    end

    it 'should have the raid level set' do
      resource[:level].should == 0
    end

    it 'should have the active_devices derived' do
      resource[:active_devices].should == 2
    end

    defaults = { :spare_devices => nil,
                 :chunk => nil,
                 :parity => nil,
                 :bitmap => nil,
                 :generate_conf => true,
                 :force => false,
    }

    defaults.each_pair do |param, value|
      it "should have #{param} parameter set to #{value}" do
        resource[param].should == value
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
                          :generate_conf => false,
                          :force => true,
                          :provider => provider)

    end

    it { resource[:devices].should == ['/dev/sdb', '/dev/sdc', '/dev/sdd', '/dev/sde'] }
    it { resource[:level].should == 5 }
    it { resource[:ensure].should == :created }
    it { resource[:active_devices].should == 3 }
    it { resource[:spare_devices].should == 1}
    it { resource[:parity].should == :'right-symmetric' }
    it { resource[:bitmap].should == '/tmp/bitmap' }
    it { resource[:generate_conf].should == false }
    it { resource[:force].should == true }
  end

  describe 'resource with invalid ensure' do
    let(:resource) do
      described_class.new(:name => '/dev/md1',
                          :devices => ['/dev/sdb', '/dev/sdc'],
                          :level => 0,
                          :ensure => :present,
                          :provider => provider)

    end
    it { expect { resource }.to raise_error(Puppet::ResourceError,
        /Invalid value :present. Valid values are created, assembled, absent./)
    }
  end

  describe 'resource with invalid :generate_conf' do
    let(:resource) do
      described_class.new(:name => '/dev/md1',
                          :devices => ['/dev/sdb', '/dev/sdc'],
                          :level => 0,
                          :generate_conf => 'foo',
                          :provider => provider)

    end
    it { expect { resource }.to raise_error(Puppet::ResourceError, /expected a boolean value/) }
  end

  describe 'resource with invalid :force' do
    let(:resource) do
      described_class.new(:name => '/dev/md1',
                          :devices => ['/dev/sdb', '/dev/sdc'],
                          :level => 0,
                          :force => 'foo',
                          :provider => provider)

    end
    it { expect { resource }.to raise_error(Puppet::ResourceError, /expected a boolean value/) }
  end

  describe 'resource without required params' do
    let(:resource) do
      described_class.new(:name => '/dev/md1')
    end
    it { expect { resource }.to raise_error(Puppet::ResourceError, /Both devices and level are required attributes/ ) }
  end

  describe 'resource with mismatched :level and :parity' do
    let(:resource) do
      described_class.new(:name => '/dev/md1',
                          :devices => ['/dev/sdb', '/dev/sdc'],
                          :level => 1,
                          :parity => 'left-asymmetric',
                          :provider => provider)
    end
    it { expect { resource }.to raise_error(Puppet::ResourceError, /Parity can only be set on raid5\/6/) }
  end

  describe 'resource with invalid parity' do
    let(:resource) do
      described_class.new(:name => '/dev/md1',
                          :devices => ['/dev/sdb', '/dev/sdc'],
                          :level => 5,
                          :parity => 'foo',
                          :provider => provider)
    end
    it { expect { resource }.to raise_error(Puppet::ResourceError,
        /Invalid value "foo". Valid values are left-symmetric, right-symmetric, left-asymmetric, right-asymmetric/ ) }
  end

  describe 'when changing the ensure' do
    it 'should be in sync if it is :absent and should be :absent' do
      ensureprop.should = :absent
      ensureprop.safe_insync?(:absent).should == true
    end

    it 'should be out of sync if it is :absent and should be :created' do
      ensureprop.should = :created
      ensureprop.safe_insync?(:absent).should == false
    end

    it 'should be out of sync if it is :absent and should be :assembled' do
      ensureprop.should = :assembled
      ensureprop.safe_insync?(:absent).should == false
    end

    it 'should be in sync if it should be :stopped and should be :absent' do
      ensureprop.should = :stopped
      ensureprop.safe_insync?(:absent).should == true
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
      req.size.should == 1
    end
  end
end
