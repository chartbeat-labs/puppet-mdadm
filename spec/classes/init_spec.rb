require 'spec_helper'

describe 'mdadm' do
  context 'supported operating systems' do
    ['Debian'].each do |osfamily|
      describe "mdadm class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
          :lsbdistrelease => '12.04',
        }}

        it { should contain_class('mdadm::params') }

        it { should contain_class('mdadm::install') }
        it { should contain_class('mdadm::config') }
        it { should contain_class('mdadm::service') }
      end
    end
  end

  context 'unsupported operating system' do
    describe 'mdadm class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { should raise_error(Puppet::Error, /Nexenta not supported/) }}
    end
  end
end
