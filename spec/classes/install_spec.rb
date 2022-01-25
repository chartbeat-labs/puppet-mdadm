require 'spec_helper'

describe 'mdadm', :type => :class do
  on_supported_os.each do |os, facts|
    describe "mdadm::install class on #{os}" do
      # Default facts used for contexts
      let(:facts) { facts }

      context 'with no parameters' do
        it { should contain_package('mdadm') }
      end

      context 'with parameters' do
        let(:params) {{
          :package_name => 'raidtools',
          :package_ensure => '1.2.3',
        }}

        it { should contain_package('raidtools').with({
          'ensure' => '1.2.3'
        })
        }
      end
    end
  end
end
