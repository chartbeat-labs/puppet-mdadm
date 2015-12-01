require 'spec_helper'

describe 'mdadm', :type => :class do
  describe 'mdadm::config class on Debian' do
    let(:facts) {{
      :osfamily => 'Debian',
      :lsbdistrelease => '12.04',
    }}

    context 'with no parameters' do
      it { should contain_file('/etc/cron.d/mdadm').with({'ensure' => 'present'}) }
      it { should contain_file('/etc/cron.daily/mdadm').with({'ensure' => 'present'}) }
    end

    context 'with parameters' do
      let(:params) {{
        :include_cron => false,
	:include_cron_daily => false,
      }}

      it { should contain_file('/etc/cron.d/mdadm').with({'ensure' => 'absent'}) }
      it { should contain_file('/etc/cron.daily/mdadm').with({'ensure' => 'absent'}) }
    end
  end
end
