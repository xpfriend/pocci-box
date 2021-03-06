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
    describe docker_container('poccis_taiga_1') do
      it { should be_running }
    end
    describe docker_container('poccis_taigaback_1') do
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
    describe command("docker ps -a |grep poccin_nodejs |wc -l") do
      its(:stdout) { should match /^0$/ }
    end
    describe command("docker ps -a |grep poccin_java |wc -l") do
      its(:stdout) { should match /^0$/ }
    end
  end
  context 'setup.yml' do
    describe command('sed -e "s/\"/\'/g" $POCCI_DIR/template/setup.taiga.yml > /tmp/setup.yml && diff -bB /tmp/setup.yml $POCCI_DIR/config/setup.yml |wc -l') do
      its(:stdout) { should match /^0$/ }
    end
  end
end

context 'setup-proxy.sh' do
  describe file('/etc/profile.d/proxy.sh') do
    its(:content) { should match /^export http_proxy="http:\/\/172.17.0.1:8888"$/ }
    its(:content) { should match /^export https_proxy="http:\/\/172.17.0.1:8888"$/ }
    its(:content) { should match /^export ftp_proxy="http:\/\/172.17.0.1:8888"$/ }
    its(:content) { should match /^export rsync_proxy="http:\/\/172.17.0.1:8888"$/ }
    its(:content) { should match /^export no_proxy="127.0.0.1,localhost"$/ }
  end
  context 'environment' do
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
  describe file('/etc/default/docker') do
    its(:content) { should match /^\. \/etc\/profile.d\/proxy.sh$/ }
  end
end

context 'setup-mail.sh' do
  context '/etc/aliases' do
    describe command('docker exec poccis_smtp_1 grep -E "^pocci:root" /etc/aliases | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe command('docker exec poccis_smtp_1 grep -E "^boze:root" /etc/aliases | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe command('docker exec poccis_smtp_1 grep -E "^hamada:root" /etc/aliases | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
  end
  context 'spool' do
    describe command('docker exec poccis_smtp_1 grep -E "^To: pocci@localhost.localdomain$" /var/mail/root |wc -l') do
      let(:disable_sudo) { true }
      its(:stdout) { should match /^2$/ }
    end
    describe command('docker exec poccis_smtp_1 grep -E "^To: boze@localhost.localdomain$" /var/mail/root |wc -l') do
      let(:disable_sudo) { true }
      its(:stdout) { should match /^1$/ }
    end
    describe command('docker exec poccis_smtp_1 grep -E "^To: hamada@localhost.localdomain$" /var/mail/root |wc -l') do
      let(:disable_sudo) { true }
      its(:stdout) { should match /^2$/ }
    end
    describe command('docker exec poccis_smtp_1 grep -E "^From: GitLab"  /var/mail/root |wc -l') do
      let(:disable_sudo) { true }
      its(:stdout) { should match /^4$/ }
    end
    describe command('docker exec poccis_smtp_1 grep -E "^From: pocci@localhost.localdomain"  /var/mail/root |wc -l') do
      let(:disable_sudo) { true }
      its(:stdout) { should match /^1$/ }
    end
  end
end
