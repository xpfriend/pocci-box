#
# environment.sh
# --------------------------------------------------------------------
# export template="/opt/pocci-box/pocci/template file:///user_data/mytemplate/.git"
# export service_type=jo
#
# export timely_backup_hour=-
# --------------------------------------------------------------------
#
# file:///user_data/mytemplate/.git : setup.jo.yml のみを含む
# setup.jo.yml
# --------------------------------------------------------------------
# pocci:
#   domain: pocci.test
#   services:
#     - jenkins
#   environment:
#     TZ: Asia/Tokyo
#
Encoding.default_external = Encoding::UTF_8
require 'spec_helper'

context 'service type' do
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

    describe command("docker ps -a |grep kanban |wc -l") do
      its(:stdout) { should match /^0$/ }
    end

    describe command("docker ps -a |grep redmine |wc -l") do
      its(:stdout) { should match /^0$/ }
    end
  end

  context 'template' do
    describe command('diff /user_data/setup.jo.yml $POCCI_DIR/config/setup.yml |wc -l') do
      its(:stdout) { should match /^0$/ }
    end
  end
end

context 'backup' do
  context 'login shell' do
    describe command('echo $BACKUP_TYPE') do
      its(:stdout) { should match /^rsync$/ }
    end
    describe command('echo $BACKUP_SERVER') do
      its(:stdout) { should match /^$/ }
    end
    describe command('echo $BACKUP_SERVER_USER') do
      its(:stdout) { should match /^$/ }
    end
    describe command('echo $BACKUP_SERVER_DIR') do
      its(:stdout) { should match /^\/user_data\/backup$/ }
    end
  end

  context 'crontab' do
    describe cron do
      it { should have_entry('0 0 * * * /opt/pocci-box/scripts/do-backup daily').with_user('pocci') }
    end
    describe command('crontab -l | grep -E "^#0 10,12,18" | wc -l') do
      let(:disable_sudo) { true }
      its(:stdout) { should match /^1$/ }
    end
  end
end
