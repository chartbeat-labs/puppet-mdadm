require 'spec_helper'

describe 'mdadm' do

  on_supported_os.each do |os, facts|
    context "supported operating system: #{os}" do
      let(:params) {{ }}
      let(:facts) { facts }

      it { should contain_class('mdadm::params') }
      it { should contain_class('mdadm::install') }
      it { should contain_class('mdadm::config') }
      it { should contain_class('mdadm::service') }
    end
  end

  context 'unsupported operating system' do
    test_on = {
      supported_os: [
        {
          'operatingsystem'        => 'Darwin',
        },
      ],
    }

    on_supported_os(test_on).each do |os, facts|
      let(:facts) { facts }
      describe "mdadm class without any parameters on #{os}" do
        it { expect { should raise_error(Puppet::Error, /#{facts[:os]['name']} not supported/) }}
      end
    end
  end
end
