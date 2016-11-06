Encoding.default_external = Encoding::UTF_8
require 'spec_helper'

describe 'common' do
  include_examples 'common'
end

context 'setup-backup.sh' do
  describe cron do
    it { should have_entry('0 0 * * * /opt/pocci-box/scripts/do-backup daily').with_user('pocci') }
  end
  describe command('crontab -l | grep -E "^#0 10,12,18" | wc -l') do
    let(:disable_sudo) { true }
    its(:stdout) { should match /^1$/ }
  end
end

context 'setup-pocci.sh' do
  describe file('/etc/profile.d/pocci.sh') do
    its(:content) { should match /^export POCCI_TEMPLATE="\/opt\/pocci-box\/pocci\/template https:\/\/github.com\/xpfriend\/pocci-template-examples.git"$/ }
  end
  context 'docker conotainers' do
    describe docker_container('poccis_jenkins_1') do
      it { should be_running }
    end
    describe command("docker ps -a |grep ldap |wc -l") do
      its(:stdout) { should match /^0$/ }
    end
    describe command("docker ps -a |grep user |wc -l") do
      its(:stdout) { should match /^0$/ }
    end
    describe command("docker ps -a |grep gitlab |wc -l") do
      its(:stdout) { should match /^0$/ }
    end
    describe command("docker ps -a |grep sonar |wc -l") do
      its(:stdout) { should match /^0$/ }
    end
    describe command("docker ps -a |grep nodejs |wc -l") do
      its(:stdout) { should match /^0$/ }
    end
    describe command("docker ps -a |grep java |wc -l") do
      its(:stdout) { should match /^0$/ }
    end
    describe command("docker ps -a |grep taiga |wc -l") do
      its(:stdout) { should match /^0$/ }
    end
    describe command("docker ps -a |grep redmine |wc -l") do
      its(:stdout) { should match /^0$/ }
    end
  end
  context 'setup.yml' do
    describe command('sed -e "s/\"/\'/g" $POCCI_DIR/temp/template/setup-files/minimal/setup.jenkins.yml > /tmp/setup.yml && diff -bB /tmp/setup.yml $POCCI_DIR/config/setup.yml |wc -l') do
      its(:stdout) { should match /^0$/ }
    end
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
  describe command('grep -E "^Server=127.0.0.1$" /etc/zabbix/zabbix_agentd.conf | wc -l') do
    its(:stdout) { should match /^1$/ }
  end
  describe command('grep -E "^ServerActive=127.0.0.1$" /etc/zabbix/zabbix_agentd.conf | wc -l') do
    its(:stdout) { should match /^1$/ }
  end
  describe command('grep -E "^Hostname=pocci$" /etc/zabbix/zabbix_agentd.conf | wc -l') do
    its(:stdout) { should match /^1$/ }
  end
end
