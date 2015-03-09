require 'spec_helper'

describe 'mdadm::array', :type => :define do
  let(:title) do
    '/dev/md1'
  end

  let(:facts) {{
    :osfamily => 'Debian',
    :lsbdistrelease => '12.04',
  }}

  context 'when creating an array' do
    let(:params) {{
      'ensure' => 'created',
      'devices' => ['/dev/sdb', '/dev/sdc'],
      'level' => 0,
      'active_devices' => 2,
      'spare_devices' => 0,
      'chunk' => 512,
      'parity' => 'left-symmetric',
      'bitmap' => '/tmp/bitmap',
      'metadata' => '0.9',
      'force' => true,
      'generate_conf' => true,
      'update_initramfs' => true,
    }}

    it { should contain_class('mdadm') }
    it { should contain_mdadm('/dev/md1') }
  end
end
