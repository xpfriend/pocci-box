#
# environment.sh
# --------------------------------------------------------------------
# apt-get update
# apt-get -y install tinyproxy
# sed -E 's|Allow 127.0.0.1|Allow 0.0.0.0/0|' -i /etc/tinyproxy.conf
# service tinyproxy restart
#
# export http_proxy=http://172.17.0.1:8888
# export service_type=jenkins
# --------------------------------------------------------------------
Encoding.default_external = Encoding::UTF_8
require 'spec_helper'

describe 'common' do
  include_examples 'common'
end

context 'timezone' do
  describe command('timedatectl |grep Timezone') do
    its(:stdout) { should match /Etc\/UTC/ }
  end
  context 'template' do
    describe command('grep -E "TZ: Etc/UTC" $POCCI_DIR/template/*.yml | wc -l') do
      its(:stdout) { should match /^3$/ }
    end
  end
end

context 'proxy' do
  context 'login shell' do
    describe command('echo $http_proxy') do
      its(:stdout) { should match /^http:\/\/172.17.0.1:8888$/ }
    end
    describe command('echo $https_proxy') do
      its(:stdout) { should match /^http:\/\/172.17.0.1:8888$/ }
    end
    describe command('echo $ftp_proxy') do
      its(:stdout) { should match /^http:\/\/172.17.0.1:8888$/ }
    end
    describe command('echo $rsync_proxy') do
      its(:stdout) { should match /^http:\/\/172.17.0.1:8888$/ }
    end
    describe command('echo $no_proxy') do
      its(:stdout) { should match /^127.0.0.1,localhost$/ }
    end
  end
end

context 'backup' do
  context 'login shell' do
    describe command('echo $BACKUP_TYPE') do
      its(:stdout) { should match /^pretender$/ }
    end
    describe command('echo $DAILY_BACKUP_NUM') do
      its(:stdout) { should match /^2$/ }
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
      its(:stdout) { should match /^pocci@localhost.localdomain$/ }
    end
    describe command('echo $ALERT_MAIL_FROM') do
      its(:stdout) { should match /^pocci@localhost.localdomain$/ }
    end
  end
  context '/etc/main.cf' do
    describe command('grep -E "^relayhost = .+$" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^0$/ }
    end
    describe command('grep -E "^smtp_tls_security_level" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^0$/ }
    end
    describe command('grep -E "^smtp_tls_CAfile" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^0$/ }
    end
    describe command('grep -E "^smtp_sasl_auth_enable" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^0$/ }
    end
    describe command('grep -E "^smtp_sasl_security_options" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^0$/ }
    end
    describe command('grep -E "^smtp_sasl_password_maps" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^0$/ }
    end
  end
  context '/etc/aliases' do
    describe command('grep -E "^admin: pocci@localhost.localdomain$" /etc/aliases | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe command('grep -E "^boze: pocci@localhost.localdomain$" /etc/aliases | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe command('grep -E "^jenkinsci: pocci@localhost.localdomain$" /etc/aliases | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
  end
  context 'template' do
    describe command('grep -E "adminMailAddress: pocci@localhost.localdomain" $POCCI_DIR/template/*.yml | wc -l') do
      its(:stdout) { should match /^3$/ }
    end
  end
  context 'spool' do
    describe command('mail -H | wc -l') do
      let(:disable_sudo) { true }
      its(:stdout) { should match /^3$/ }
    end
    describe command('mail -p | grep -E "^To: admin@example.com$" |wc -l') do
      let(:disable_sudo) { true }
      its(:stdout) { should match /^1$/ }
    end
    describe command('mail -p | grep -E "^To: pocci@localhost.localdomain$" |wc -l') do
      let(:disable_sudo) { true }
      its(:stdout) { should match /^1$/ }
    end
    describe command('mail -p | grep -E "^To: boze@localhost.localdomain$" |wc -l') do
      let(:disable_sudo) { true }
      its(:stdout) { should match /^1$/ }
    end
    describe command('mail -p | grep -E "^From: GitLab" |wc -l') do
      let(:disable_sudo) { true }
      its(:stdout) { should match /^3$/ }
    end
  end
end

context 'redmine_lang' do
  context 'template' do
    describe command('grep -E "lang: en" $POCCI_DIR/template/setup.redmine.yml | wc -l') do
      its(:stdout) { should match /^1$/ }
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

    describe docker_container('poccis_kanban_1') do
      it { should be_running }
    end

    describe docker_container('poccis_jenkins_1') do
      it { should be_running }
    end

    describe command("docker ps -a |grep redmine |wc -l") do
      its(:stdout) { should match /^0$/ }
    end
  end

  context 'template' do
    describe command('diff $POCCI_DIR/template/setup.jenkins.yml $POCCI_DIR/config/setup.yml |wc -l') do
      its(:stdout) { should match /^0$/ }
    end
  end
end

context 'hook command' do
  context 'login shell' do
    describe command('grep -E "^export ON_STARTUP_FINISHED=\"echo Done\"" /etc/profile.d/pocci.sh | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
  end
end

