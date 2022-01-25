require 'spec_helper'

describe 'mdadm', :type => :class do
  on_supported_os.each do |os, facts|
    describe "mdadm::config class on #{os}" do
      let(:facts) { facts }
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
end
