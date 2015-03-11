require 'spec_helper'

describe 'mdadm', :type => :class do
  describe 'mdadm::config class on Debian' do
    let(:facts) {{
      :osfamily => 'Debian',
      :lsbdistrelease => '12.04',
    }}

    context 'with no parameters' do
      it { should contain_file('/etc/cron.d/mdadm') }
    end

    context 'with parameters' do
      let(:params) {{
        :include_cron => false,
      }}

      it { should_not contain_file('/etc/cron.d/mdadm') }
    end
  end
end
