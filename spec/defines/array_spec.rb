require 'spec_helper'

describe 'mdadm::array', :type => :define do
  let(:title) do
    '/dev/md1'
  end

  let(:facts) {{
    :osfamily => 'Debian'
  }}

  let(:params) {{
    'devices' => ['/dev/sdb', '/dev/sdc'],
    'level' => 0,
  }}

  context 'when creating an array' do
    let(:params) {{
      'ensure' => 'created',
      'devices' => ['/dev/sdb', '/dev/sdc'],
      'level' => 0,
    }}

    it { should contain_class('mdadm') }
    it { should contain_mdadm('/dev/md1') }
  end
end
