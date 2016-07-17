Encoding.default_external = Encoding::UTF_8
require 'spec_helper'

describe 'common' do
  include_examples 'common'
end

context 'setup-backup.sh' do
  describe file('/etc/profile.d/pocci.sh') do
    its(:content) { should match /^export DAILY_BACKUP_NUM="2"$/ }
    its(:content) { should match /^export BACKUP_TYPE="pretender"$/ }
  end
  context 'environment' do
    describe command('echo $DAILY_BACKUP_NUM') do
      its(:stdout) { should match /^2$/ }
    end
    describe command('echo $BACKUP_TYPE') do
      its(:stdout) { should match /^pretender$/ }
    end
    describe command('echo $BACKUP_SERVER') do
      its(:stdout) { should match /^$/ }
    end
    describe command('echo $BACKUP_SERVER_USER') do
      its(:stdout) { should match /^$/ }
    end
    describe command('echo $BACKUP_SERVER_DIR') do
      its(:stdout) { should match /^$/ }
    end
  end
  describe cron do
    it { should have_entry('0 0 * * * /opt/pocci-box/scripts/do-backup daily').with_user('pocci') }
    it { should have_entry('0 10,12,18 * * * /opt/pocci-box/scripts/do-backup').with_user('pocci') }
  end
end

context 'setup-hooks.sh' do
  describe file('/etc/profile.d/pocci.sh') do
    its(:content) { should match /^export ON_STARTUP_FINISHED="echo Done"$/ }
  end
  context 'environment' do
    describe command('${ON_STARTUP_FINISHED}') do
      its(:stdout) { should match /^Done$/ }
    end
  end
end

context 'setup-https.sh' do
  describe file('/etc/profile.d/pocci.sh') do
    its(:content) { should match /^export POCCI_HTTPS="false"$/ }
  end
  context 'environment' do
    describe command('echo ${POCCI_HTTPS}') do
      its(:stdout) { should match /^false$/ }
    end
  end
  describe file('/opt/pocci-box/pocci/config/.env') do
    its(:content) { should match /^POCCI_HTTPS=false$/ }
  end
end

context 'setup-notifier.sh' do
  describe file('/etc/profile.d/pocci.sh') do
    its(:content) { should match /^export NOTIFIER="mail"$/ }
  end
  context 'environment' do
    describe command('echo $NOTIFIER') do
      its(:stdout) { should match /^mail$/ }
    end
  end
  describe file('/etc/init/zabbix-agent.conf') do
    it { should_not be_exist }
  end
end

context 'setup-ntp.sh' do
  describe command('grep -E "^server" /etc/ntp.conf | wc -l') do
    its(:stdout) { should match /^5$/ }
  end
  describe command('grep -E "^server .\.ubuntu\.pool\.ntp\.org" /etc/ntp.conf | wc -l') do
    its(:stdout) { should match /^4$/ }
  end
  describe command('grep -E "^server ntp\.ubuntu\\.com" /etc/ntp.conf | wc -l') do
    its(:stdout) { should match /^1$/ }
  end
end

context 'setup-pocci.sh' do
  describe file('/etc/profile.d/pocci.sh') do
    its(:content) { should match /^export POCCI_TEMPLATE="template"$/ }
    its(:content) { should match /^export POCCI_DOMAIN_NAME="pocci.test"$/ }
  end
  context 'environment' do
    describe command('echo $POCCI_TEMPLATE') do
      its(:stdout) { should match /^template$/ }
    end
    describe command('echo $POCCI_DOMAIN_NAME') do
      its(:stdout) { should match /^pocci.test$/ }
    end
  end
  describe file('/opt/pocci-box/pocci/config/.env') do
    its(:content) { should match /^POCCI_DOMAIN_NAME=pocci.test$/ }
  end
  context 'docker conotainers' do
    describe docker_container('poccis_ldap_1') do
      it { should be_running }
    end
    describe docker_container('poccis_user_1') do
      it { should be_running }
    end
    describe docker_container('poccis_gitlab_1') do
      it { should be_running }
    end
    describe docker_container('poccis_sonar_1') do
      it { should be_running }
    end
    describe docker_container('poccin_nodejs_1') do
      it { should be_running }
    end
    describe docker_container('poccin_java_1') do
      it { should be_running }
    end
    describe docker_container('poccis_kanban_1') do
      it { should be_running }
    end
    describe docker_container('poccis_smtp_1') do
      it { should be_running }
    end
    describe command("docker ps -a |grep jenkins |wc -l") do
      its(:stdout) { should match /^0$/ }
    end
    describe command("docker ps -a |grep redmine |wc -l") do
      its(:stdout) { should match /^0$/ }
    end
  end
  context 'setup.yml' do
    describe command('diff $POCCI_DIR/template/setup.default.yml $POCCI_DIR/config/setup.yml |wc -l') do
      its(:stdout) { should match /^0$/ }
    end
  end
end

context 'setup-postfix.sh' do
  describe file('/etc/profile.d/pocci.sh') do
    its(:content) { should_not match /^export SMTP_RELAYHOST=/ }
    its(:content) { should_not match /^export SMTP_PASSWORD=/ }
    its(:content) { should match /^export ADMIN_MAIL_ADDRESS="pocci@localhost.localdomain"$/ }
    its(:content) { should match /^export ALERT_MAIL_FROM="pocci@localhost.localdomain"$/ }
  end
  context 'environment' do
    describe command('echo $ADMIN_MAIL_ADDRESS') do
      its(:stdout) { should match /^pocci@localhost.localdomain$/ }
    end
    describe command('echo $ALERT_MAIL_FROM') do
      its(:stdout) { should match /^pocci@localhost.localdomain$/ }
    end
  end
  describe file('/opt/pocci-box/pocci/config/.env') do
    its(:content) { should match /^ADMIN_MAIL_ADDRESS=pocci@localhost.localdomain$/ }
  end
  context '/etc/postfix/main.cf' do
    describe command('docker exec poccis_smtp_1 grep -E "^relayhost = .+$" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^0$/ }
    end
    describe command('docker exec poccis_smtp_1 grep -E "^smtp_tls_security_level" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^0$/ }
    end
    describe command('docker exec poccis_smtp_1 grep -E "^smtp_tls_CAfile" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^0$/ }
    end
    describe command('docker exec poccis_smtp_1 grep -E "^smtp_sasl_auth_enable" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^0$/ }
    end
    describe command('docker exec poccis_smtp_1 grep -E "^smtp_sasl_security_options" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^0$/ }
    end
    describe command('docker exec poccis_smtp_1 grep -E "^smtp_sasl_password_maps" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^0$/ }
    end
  end
  context '/etc/postfix/smtp_password' do
    describe command('docker exec poccis_smtp_1 ls /etc/postfix/smtp_password | wc -l') do
      its(:stdout) { should match /^0$/ }
    end
    describe command('docker exec poccis_smtp_1 ls /etc/postfix/smtp_password.db | wc -l') do
      its(:stdout) { should match /^0$/ }
    end
  end
  context '/etc/aliases' do
    describe command('docker exec poccis_smtp_1 grep -E "^pocci:root" /etc/aliases | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe command('docker exec poccis_smtp_1 grep -E "^boze:root" /etc/aliases | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
  end
  context 'spool' do
    describe command('docker exec poccis_smtp_1 grep -E "^To: pocci@localhost.localdomain$" /var/mail/root |wc -l') do
      let(:disable_sudo) { true }
      its(:stdout) { should match /^1$/ }
    end
    describe command('docker exec poccis_smtp_1 grep -E "^To: boze@localhost.localdomain$" /var/mail/root |wc -l') do
      let(:disable_sudo) { true }
      its(:stdout) { should match /^1$/ }
    end
    describe command('docker exec poccis_smtp_1 grep -E "^From: GitLab"  /var/mail/root |wc -l') do
      let(:disable_sudo) { true }
      its(:stdout) { should match /^2$/ }
    end
  end
end

context 'setup-proxy.sh' do
  describe file('/etc/profile.d/proxy.sh') do
    its(:size) { should eq 0 }
  end
  describe file('/etc/default/docker') do
    its(:content) { should_not match /^export .+_proxy/ }
  end
end

context 'setup-timezone.sh' do
  describe command('timedatectl |grep Timezone') do
    its(:stdout) { should match /Etc\/UTC/ }
  end
  describe file('/etc/profile.d/pocci.sh') do
    its(:content) { should match /^export TZ="Etc\/UTC"$/ }
  end
  context 'environment' do
    describe command('echo ${TZ}') do
      its(:stdout) { should match /^Etc\/UTC$/ }
    end
  end
  describe file('/opt/pocci-box/pocci/config/.env') do
    its(:content) { should match /^TZ=Etc\/UTC$/ }
  end
end
