Encoding.default_external = Encoding::UTF_8
require 'spec_helper'

describe 'common' do
  include_examples 'common'
end

context 'setup.sh' do
  describe file('/tmp/provisioning_finished.txt') do
    it { should be_file }
  end
end

context 'setup-backup.sh' do
  describe file('/etc/profile.d/pocci.sh') do
    its(:content) { should match /^export DAILY_BACKUP_NUM="3"$/ }
    its(:content) { should match /^export BACKUP_TYPE="rsync"$/ }
    its(:content) { should match /^export BACKUP_SERVER="localhost"$/ }
    its(:content) { should match /^export BACKUP_SERVER_USER="user01"$/ }
    its(:content) { should match /^export BACKUP_SERVER_DIR="\/home\/user01\/backup"$/ }
  end
  context 'environment' do
    describe command('echo $DAILY_BACKUP_NUM') do
      its(:stdout) { should match /^3$/ }
    end
    describe command('echo $BACKUP_TYPE') do
      its(:stdout) { should match /^rsync$/ }
    end
    describe command('echo $BACKUP_SERVER') do
      its(:stdout) { should match /^localhost$/ }
    end
    describe command('echo $BACKUP_SERVER_USER') do
      its(:stdout) { should match /^user01$/ }
    end
    describe command('echo $BACKUP_SERVER_DIR') do
      its(:stdout) { should match /^\/home\/user01\/backup$/ }
    end
  end
  describe cron do
    it { should have_entry('0 1 * * * /opt/pocci-box/scripts/do-backup daily').with_user('pocci') }
    it { should have_entry('0 2,19 * * * /opt/pocci-box/scripts/do-backup').with_user('pocci') }
  end
end

context 'setup-hooks.sh' do
  describe file('/etc/profile.d/pocci.sh') do
    its(:content) { should match /^export ON_STARTUP_FINISHED="touch \/tmp\/startup_finished.txt"$/ }
  end
  context 'environment' do
    describe command('rm /tmp/startup_finished.txt') do
    end
    describe command('echo $ON_STARTUP_FINISHED') do
      its(:stdout) { should match /^touch/}
    end
  end
end

context 'setup-ntp.sh' do
  describe command('grep -E "^server" /etc/ntp.conf | wc -l') do
    its(:stdout) { should match /^2$/ }
  end
  describe command('grep -E "^server ntp\.nict\.jp" /etc/ntp.conf | wc -l') do
    its(:stdout) { should match /^1$/ }
  end
  describe command('grep -E "^server ntp\.ubuntu\.com" /etc/ntp.conf | wc -l') do
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
    describe docker_container('poccis_jenkins_1') do
      it { should be_running }
    end
    describe docker_container('poccis_redmine_1') do
      it { should be_running }
    end
    describe docker_container('poccis_smtp_1') do
      it { should be_running }
    end
    describe command("docker ps -a |grep kanban |wc -l") do
      its(:stdout) { should match /^0$/ }
    end
  end
  context 'setup.yml' do
    describe command('diff $POCCI_DIR/template/setup.redmine.yml $POCCI_DIR/config/setup.yml |wc -l') do
      its(:stdout) { should match /^0$/ }
    end
  end
end

context 'setup-postfix.sh' do
  describe file('/etc/profile.d/pocci.sh') do
    its(:content) { should match /^export SMTP_RELAYHOST="#{ENV['test_smtp_relayhost'].gsub('[', '\[')}"$/ }
    its(:content) { should match /^export SMTP_PASSWORD="#{ENV['test_smtp_password']}"$/ }
    its(:content) { should match /^export ADMIN_MAIL_ADDRESS="#{ENV['test_admin_mail_address']}"$/ }
    its(:content) { should match /^export ALERT_MAIL_FROM="#{ENV['test_alert_mail_from']}"$/ }
  end
  context 'environment' do
    describe command('echo $SMTP_RELAYHOST') do
      its(:stdout) { should match /^#{ENV['test_smtp_relayhost'].gsub('[', '\[')}$/ }
    end
    describe command('echo $SMTP_PASSWORD') do
      its(:stdout) { should match /^#{ENV['test_smtp_password']}$/ }
    end
    describe command('echo $ADMIN_MAIL_ADDRESS') do
      its(:stdout) { should match /^#{ENV['test_admin_mail_address']}$/ }
    end
    describe command('echo $ALERT_MAIL_FROM') do
      its(:stdout) { should match /^#{ENV['test_alert_mail_from']}$/ }
    end
  end
  describe file('/opt/pocci-box/pocci/config/.env') do
    its(:content) { should match /^SMTP_RELAYHOST=#{ENV['test_smtp_relayhost'].gsub('[', '\[')}$/ }
    its(:content) { should match /^SMTP_PASSWORD=#{ENV['test_smtp_password']}$/ }
    its(:content) { should match /^ADMIN_MAIL_ADDRESS=#{ENV['test_admin_mail_address']}$/ }
  end
  context '/etc/postfix/main.cf' do
    describe command('docker exec poccis_smtp_1 grep -E "^relayhost = ' + ENV['test_smtp_relayhost'].gsub('[', '\[') +
                     '$" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe command('docker exec poccis_smtp_1 grep -E "^smtp_tls_security_level = may$" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe command('docker exec poccis_smtp_1 grep -E "^smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt$" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe command('docker exec poccis_smtp_1 grep -E "^smtp_sasl_auth_enable = yes$" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe command('docker exec poccis_smtp_1 grep -E "^smtp_sasl_security_options = noanonymous$" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe command('docker exec poccis_smtp_1 grep -E "^smtp_sasl_password_maps = hash:/etc/postfix/smtp_password$" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
  end
  context '/etc/postfix/smtp_password' do
    describe command('docker exec poccis_smtp_1 ls /etc/postfix/smtp_password | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe command('docker exec poccis_smtp_1 ls /etc/postfix/smtp_password.db | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe command('docker exec poccis_smtp_1 grep -E "^' + ENV['test_smtp_relayhost'].gsub('[', '\[') + ' ' +
                    ENV['test_smtp_password'] + '$" /etc/postfix/smtp_password | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
  end
  context '/etc/aliases' do
    describe command('docker exec poccis_smtp_1 grep -E "^boze:' + ENV['test_admin_mail_address'] + '$" /etc/aliases | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe command('docker exec poccis_smtp_1 grep -E "^jenkins-ci:' + ENV['test_admin_mail_address'] + '$" /etc/aliases | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
  end
  context 'spool' do
    describe command('docker exec poccis_smtp_1 mail') do
      let(:disable_sudo) { true }
      its(:stderr) { should match /^No mail for root$/ }
    end
  end
end

context 'setup-timezone.sh' do
  describe command('timedatectl |grep Timezone') do
    its(:stdout) { should match /Asia\/Tokyo/ }
  end
  describe file('/etc/profile.d/pocci.sh') do
    its(:content) { should match /^export TZ="Asia\/Tokyo"$/ }
  end
  context 'environment' do
    describe command('echo ${TZ}') do
      its(:stdout) { should match /^Asia\/Tokyo$/ }
    end
  end
  describe file('/opt/pocci-box/pocci/config/.env') do
    its(:content) { should match /^TZ=Asia\/Tokyo$/ }
  end
end
