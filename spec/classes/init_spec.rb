require 'spec_helper'

describe 'mdadm' do
  context 'supported operating systems' do
    let(:params) {{ }}
    let(:facts) {{
      :osfamily => 'Debian',
      :operatingsystem => 'Ubuntu',
      :operatingsystemrelease => '12.04',
    }}
      it { should contain_class('mdadm::params') }

      it { should contain_class('mdadm::install') }
      it { should contain_class('mdadm::config') }
      it { should contain_class('mdadm::service') }
  end

  context 'unsupported operating system' do
    describe 'mdadm class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
        :operatingsystemrelease => '4',
      }}

      it { expect { should raise_error(Puppet::Error, /Nexenta not supported/) }}
    end
  end
end
