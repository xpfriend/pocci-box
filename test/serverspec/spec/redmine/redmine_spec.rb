Encoding.default_external = Encoding::UTF_8
require 'spec_helper'

describe 'common' do
  include_examples 'common'
end

context 'timezone' do
  describe command('timedatectl |grep Timezone') do
    its(:stdout) { should match /Asia\/Tokyo/ }
  end
  context 'template' do
    describe command('grep -E "TZ: Asia/Tokyo" $POCCI_DIR/template/*.yml | wc -l') do
      its(:stdout) { should match /^3$/ }
    end
  end
end

context 'ntp' do
    describe command('grep -E "^server" /etc/ntp.conf | wc -l') do
      its(:stdout) { should match /^2$/ }
    end
    describe command('grep -E "^server ntp.nict.jp" /etc/ntp.conf | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe command('grep -E "^server ntp.ubuntu.com" /etc/ntp.conf | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
end

context 'proxy' do
  context 'login shell' do
    describe file('/etc/profile.d/proxy.sh') do
      its(:size) { should eq 0 }
    end
  end
end

context 'backup' do
  context 'login shell' do
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

context 'notify tools' do
  context 'login shell' do
    describe command('echo $NOTIFIER') do
      its(:stdout) { should match /^mail$/ }
    end
  end
end

context 'mail' do
  context 'login shell' do
    describe command('echo $ADMIN_MAIL_ADDRESS') do
      its(:stdout) { should match /^#{ENV['test_admin_mail_address']}$/ }
    end
    describe command('echo $ALERT_MAIL_FROM') do
      its(:stdout) { should match /^#{ENV['test_alert_mail_from']}$/ }
    end
  end

  context '/etc/main.cf' do
    describe command('grep -E "^relayhost = ' + ENV['test_smtp_relayhost'].gsub('[', '\[') +
                     '$" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe command('grep -E "^smtp_tls_security_level = may$" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe command('grep -E "^smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt$" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe command('grep -E "^smtp_sasl_auth_enable = yes$" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe command('grep -E "^smtp_sasl_security_options = noanonymous$" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe command('grep -E "^smtp_sasl_password_maps = hash:/etc/postfix/smtp_password$" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe command('grep -E "^' + ENV['test_smtp_relayhost'].gsub('[', '\[') + ' ' +
                    ENV['test_smtp_password'] + '$" /etc/postfix/smtp_password | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe file('/etc/postfix/smtp_password') do
      it { should be_file }
    end
    describe file('/etc/postfix/smtp_password.db') do
      it { should be_file }
    end
  end

  context '/etc/aliases' do
    describe command('grep -E "^admin: ' + ENV['test_admin_mail_address'] + '$" /etc/aliases | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe command('grep -E "^boze: ' + ENV['test_admin_mail_address'] + '$" /etc/aliases | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe command('grep -E "^jenkinsci: ' + ENV['test_admin_mail_address'] + '$" /etc/aliases | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
  end
  context 'template' do
    describe command('grep -E "adminMailAddress: ' + ENV['test_admin_mail_address'] + '" $POCCI_DIR/template/*.yml | wc -l') do
      its(:stdout) { should match /^3$/ }
    end
  end
  context 'spool' do
    describe command('mail -H') do
      let(:disable_sudo) { true }
      its(:stdout) { should match /^No mail for pocci$/ }
    end
  end
end

context 'service type' do
  context 'login shell' do
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

    describe command("docker ps -a |grep kanban |wc -l") do
      its(:stdout) { should match /^0$/ }
    end
  end

  context 'template' do
    describe command('diff $POCCI_DIR/template/setup.redmine.yml $POCCI_DIR/config/setup.yml |wc -l') do
      its(:stdout) { should match /^0$/ }
    end
  end
end

context 'hook command' do
  context 'on_provisioning_finished' do
      describe file('/tmp/provisioning_finished.txt') do
        it { should be_file }
      end
  end
  context 'on_startup_finished' do
    describe command('grep -E "^export ON_STARTUP_FINISHED=\"touch /tmp/startup_finished.txt\"" /etc/profile.d/pocci.sh | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
  end
end
