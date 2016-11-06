Encoding.default_external = Encoding::UTF_8
require 'spec_helper'

describe 'common' do
  include_examples 'common'
end

context 'setup-backup.sh' do
  describe cron do
    it { should have_entry('0 10,12,18 * * * /opt/pocci-box/scripts/do-backup').with_user('pocci') }
  end
  describe command('crontab -l | grep -E "^#0 0 " | wc -l') do
    let(:disable_sudo) { true }
    its(:stdout) { should match /^1$/ }
  end
end

context 'setup-ntp.sh' do
  describe command('grep -E "^server" /etc/ntp.conf | wc -l') do
    its(:stdout) { should match /^1$/ }
  end
  describe command('grep -E "^server ntp\.nict\.jp" /etc/ntp.conf | wc -l') do
    its(:stdout) { should match /^1$/ }
  end
end

context 'setup-pocci.sh' do
  describe file('/etc/profile.d/pocci.sh') do
    its(:content) { should match /^export POCCI_TEMPLATE="template"$/ }
  end
  context 'environment' do
    describe command('echo $POCCI_TEMPLATE') do
      its(:stdout) { should match /^template$/ }
    end
  end
  context 'docker conotainers' do
    describe docker_container('poccis_jenkins_1') do
      it { should be_running }
    end
    describe docker_container('poccis_smtp_1') do
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
    describe command('sed -e "s/\"/\'/g" /user_data/setup.jo.yml > /tmp/setup.yml && diff -bB /tmp/setup.yml $POCCI_DIR/config/setup.yml |wc -l') do
      its(:stdout) { should match /^0$/ }
    end
  end
end

context 'setup-mail.sh' do
  describe file('/etc/profile.d/pocci.sh') do
    its(:content) { should match /^export ADMIN_MAIL_ADDRESS="pocci@example.com"$/ }
    its(:content) { should match /^export ALERT_MAIL_FROM="pocci@example.com"$/ }
  end
  context 'environment' do
    describe command('echo $ADMIN_MAIL_ADDRESS') do
      its(:stdout) { should match /^pocci@example.com$/ }
    end
    describe command('echo $ALERT_MAIL_FROM') do
      its(:stdout) { should match /^pocci@example.com$/ }
    end
  end
  context '/etc/aliases' do
    describe command('docker exec poccis_smtp_1 grep -E "^pocci:root$" /etc/aliases | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
  end
end

context 'setup-proxy.sh' do
  describe file('/etc/profile.d/proxy.sh') do
    its(:content) { should match /^export http_proxy="http:\/\/proxy.http.example.com\/"$/ }
    its(:content) { should match /^export https_proxy="http:\/\/proxy.https.example.com\/"$/ }
    its(:content) { should match /^export ftp_proxy="http:\/\/proxy.ftp.example.com\/"$/ }
    its(:content) { should match /^export rsync_proxy="http:\/\/proxy.rsync.example.com\/"$/ }
    its(:content) { should match /^export no_proxy="localhost"$/ }
  end
  context 'environment' do
    describe command('echo $http_proxy') do
      its(:stdout) { should match /^http:\/\/proxy.http.example.com\/$/ }
    end
    describe command('echo $https_proxy') do
      its(:stdout) { should match /^http:\/\/proxy.https.example.com\/$/ }
    end
    describe command('echo $ftp_proxy') do
      its(:stdout) { should match /^http:\/\/proxy.ftp.example.com\/$/ }
    end
    describe command('echo $rsync_proxy') do
      its(:stdout) { should match /^http:\/\/proxy.rsync.example.com\/$/ }
    end
    describe command('echo $no_proxy') do
      its(:stdout) { should match /^localhost$/ }
    end
  end
  describe file('/etc/default/docker') do
    its(:content) { should match /^\. \/etc\/profile.d\/proxy.sh$/ }
  end
end
