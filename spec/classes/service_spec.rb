require 'spec_helper'

describe 'mdadm', :type => :class do
  describe 'cron::config class on Debian' do
    # Default facts used for contexts
    let(:facts) {{
      :osfamily => 'Debian',
      :lsbdistrelease => '12.04',
    }}

    context 'with no parameters' do
      it { should contain_service('mdadm').with({
        :ensure => 'running',
        :hasstatus => true,
        })
      }
    end

    context 'with different service name' do
      let(:params) {{
        :service_name => 'mdmonitor',
      }}

      it { should contain_service('mdmonitor') }
    end

    context 'with service stopped' do
      let(:params) {{
        :service_ensure => 'stopped',
      }}

      it { should contain_service('mdadm').with({
        :ensure => 'stopped',
        })
      }
    end

    context 'with service unmanaged' do
      let(:params) {{
        :service_manage => false
      }}

      it { should_not contain_service('mdadm') }
    end

    context 'with older mdadm package' do
      let(:facts) {{
        :osfamily => 'Debian',
        :lsbdistrelease => '10.04',
      }}

      it { should contain_service('mdadm').with({
        :hasstatus => false,
        })
      }
    end

    context 'with hassstatus overriden' do
      let(:params) {{
        :service_hasstatus => false
      }}
      it { should contain_service('mdadm').with({
        :hasstatus => false,
        })
      }
    end
  end
end
