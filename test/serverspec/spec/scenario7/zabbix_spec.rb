Encoding.default_external = Encoding::UTF_8
require 'spec_helper'

describe 'common' do
  include_examples 'common'
end

context 'setup-https.sh' do
  describe file('/etc/profile.d/pocci.sh') do
    its(:content) { should match /^export POCCI_HTTPS="true"$/ }
  end
  context 'environment' do
    describe command('echo ${POCCI_HTTPS}') do
      its(:stdout) { should match /^true$/ }
    end
  end
  describe file('/opt/pocci-box/pocci/config/.env') do
    its(:content) { should match /^POCCI_HTTPS=true$/ }
  end
end

context 'setup-notifier.sh' do
  describe file('/etc/profile.d/pocci.sh') do
    its(:content) { should match /^export NOTIFIER="zabbix"$/ }
  end
  context 'environment' do
    describe command('echo $NOTIFIER') do
      its(:stdout) { should match /^zabbix$/ }
    end
  end
  describe file('/etc/init/zabbix-agent.conf') do
    it { should be_file }
  end
  describe command('grep -E "^Server=172.17.0.7$" /etc/zabbix/zabbix_agentd.conf | wc -l') do
    its(:stdout) { should match /^1$/ }
  end
  describe command('grep -E "^ServerActive=172.17.0.7$" /etc/zabbix/zabbix_agentd.conf | wc -l') do
    its(:stdout) { should match /^1$/ }
  end
  describe command('grep -E "^Hostname=pocci$" /etc/zabbix/zabbix_agentd.conf | wc -l') do
    its(:stdout) { should match /^1$/ }
  end
end

context 'setup-pocci.sh' do
  describe file('/etc/profile.d/pocci.sh') do
    its(:content) { should match /^export POCCI_DOMAIN_NAME="pocci.example.com"$/ }
  end
  context 'environment' do
    describe command('echo $POCCI_DOMAIN_NAME') do
      its(:stdout) { should match /^pocci.example.com$/ }
    end
  end
  describe file('/opt/pocci-box/pocci/config/.env') do
    its(:content) { should match /^POCCI_DOMAIN_NAME=pocci.example.com$/ }
  end
end
