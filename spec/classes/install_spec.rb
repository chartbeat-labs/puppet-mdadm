require 'spec_helper'

describe 'mdadm', :type => :class do
  describe 'mdadm::config class on Debian' do
    # Default facts used for contexts
    let(:facts) {{
      :osfamily => 'Debian',
      :lsbdistrelease => '12.04',
    }}

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
