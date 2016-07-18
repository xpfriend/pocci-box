shared_examples 'common' do

  context 'variables.json' do
    describe command('hostname') do
      its(:stdout) { should match /^pocci$/ }
    end

    context 'user' do
      @user = 'pocci'

      describe group(@user) do
        it { should exist }
        it { should have_gid 1000 }
      end

      describe user(@user) do
        it { should exist }
        it { should have_uid 1000 }
        it { should belong_to_group 'pocci' }
        it { should have_home_directory '/home/pocci' }
        it { should have_login_shell '/bin/bash' }
      end
    end

    describe service('docker') do
      it { should be_enabled }
      it { should be_running }
    end
  end

  context 'custom-script.sh' do
    describe '/root/scripts' do
      describe file('/root/scripts') do
        it { should be_directory }
        it { should be_owned_by('root') }
        it { should be_grouped_into('root') }
      end
      describe file('/root/scripts/setup.sh') do
        it { should be_executable }
      end
      describe file('/root/scripts/setup-backup.sh') do
        it { should be_executable }
      end
      describe file('/root/scripts/setup-crontab.sh') do
        it { should be_executable }
      end
      describe file('/root/scripts/setup-hooks.sh') do
        it { should be_executable }
      end
      describe file('/root/scripts/setup-notifier.sh') do
        it { should be_executable }
      end
      describe file('/root/scripts/setup-ntp.sh') do
        it { should be_executable }
      end
      describe file('/root/scripts/setup-pocci.sh') do
        it { should be_executable }
      end
      describe file('/root/scripts/setup-postfix.sh') do
        it { should be_executable }
      end
      describe file('/root/scripts/setup-proxy.sh') do
        it { should be_executable }
      end
      describe file('/root/scripts/setup-redmine_lang.sh') do
        it { should_not be_exist }
      end
      describe file('/root/scripts/setup-timezone.sh') do
        it { should be_executable }
      end
    end
    %w{/opt/pocci-box /opt/pocci-box/scripts /opt/pocci-box/pocci /opt/pocci-box/kanban/.git}.each do |dir|
      describe file(dir) do
        it { should be_directory }
        it { should be_owned_by('pocci') }
        it { should be_grouped_into('pocci') }
      end
    end
    describe file('/home/pocci/scripts') do
      it { should_not be_exist }
    end

    context '/opt/pocci-box/scripts' do
      describe file('/opt/pocci-box/scripts/backup') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/do-backup') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/init-env') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/notify') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/notify-by-mail') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/notify-by-zabbix') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/pull-backup-files') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/pull-backup-files-by-pretender') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/pull-backup-files-by-rsync') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/push-backup-files') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/push-backup-files-by-pretender') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/push-backup-files-by-rsync') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/start') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/watch-disk-usage') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/watch-docker-process') do
        it { should be_executable }
      end
    end

    %w{/etc/profile.d/pocci.sh /etc/profile.d/pocci}.each do |f|
      describe file(f) do
        it { should be_file }
        its(:content) { should match /^export POCCI_BOX_DIR="\/opt\/pocci-box"$/ }
        its(:content) { should match /^export RUNTIME_SCRIPTS_DIR="\/opt\/pocci-box\/scripts"$/ }
        its(:content) { should match /^export POCCI_DIR="\/opt\/pocci-box\/pocci"$/ }
        its(:content) { should match /^export KANBAN_REPOSITORY="\/opt\/pocci-box\/kanban\/.git"$/ }
      end
    end
    context 'environment' do
      describe command('echo $POCCI_BOX_DIR') do
        its(:stdout) { should match /^\/opt\/pocci-box$/ }
      end
      describe command('echo $RUNTIME_SCRIPTS_DIR') do
        its(:stdout) { should match /^\/opt\/pocci-box\/scripts$/ }
      end
      describe command('echo $POCCI_DIR') do
        its(:stdout) { should match /^\/opt\/pocci-box\/pocci$/ }
      end
      describe command('echo $KANBAN_REPOSITORY') do
        its(:stdout) { should match /^\/opt\/pocci-box\/kanban\/.git$/ }
      end
    end
    %w{atsar git zabbix-agent docker-engine}.each do |pkg|
      describe package(pkg) do
        it { should be_installed }
      end
    end
    %w{postfix}.each do |pkg|
      describe package(pkg) do
        it { should_not be_installed }
      end
    end
    describe command('docker-compose --version') do
      its(:stdout) { should match /version 1\.7\.1/ }
    end
    describe file('/etc/default/docker') do
      its(:content) { should match /^DOCKER_OPTS="--log-opt max-size=10m --log-opt max-file=10"$/ }
    end
    describe file('/home/pocci/.gitconfig') do
      its(:content) { should match /email = pocci@localhost.localdomain/ }
      its(:content) { should match /name = Pocci/ }
    end
    describe command("docker images |awk 'NR>1'|sort |awk '{printf \"%s \", $1 }'") do
      let(:disable_sudo) { true }
      its(:stdout) { should match /^devries\/dnsmasq gitlab\/gitlab-runner leanlabs\/kanban leanlabs\/nginx leanlabs\/redis nginx osixia\/openldap sameersbn\/gitlab sameersbn\/postgresql sameersbn\/redis sameersbn\/redmine xpfriend\/fluentd xpfriend\/jenkins xpfriend\/pocci-account-center xpfriend\/postfix xpfriend\/sonarqube xpfriend\/workspace-base xpfriend\/workspace-java xpfriend\/workspace-nodejs $/ }
    end
  end

  context 'setup.sh' do
    describe file('/etc/profile.d/pocci.sh') do
      its(:content) { should match /^export POCCI_USER="pocci"$/ }
    end
    context 'environment' do
      describe command('echo $POCCI_USER') do
        its(:stdout) { should match /^pocci$/ }
      end
    end
  end

  context 'setup-backup.sh' do
    describe file('/etc/profile.d/pocci.sh') do
      its(:content) { should match /^export BACKUP_DIR="\/opt\/pocci-box\/backup"$/ }
    end
    context 'environment' do
      describe command('echo $BACKUP_DIR') do
        its(:stdout) { should match /^\/opt\/pocci-box\/backup$/ }
      end
    end
    %w{/opt/pocci-box/backup /opt/pocci-box/backup/daily /opt/pocci-box/backup/timely}.each do |dir|
      describe file(dir) do
        it { should be_directory }
        it { should be_owned_by('pocci') }
        it { should be_grouped_into('pocci') }
      end
    end
  end

  context 'setup-crontab.sh' do
    describe command('crontab -l | grep -E "MAILTO=\"\"" | wc -l') do
      let(:disable_sudo) { true }
      its(:stdout) { should match /^1$/ }
    end
    describe command('ls /tmp/*task-schedule.txt') do
      its(:exit_status) { should eq 2 }
    end
  end

  context 'setup-notifier.sh' do
    describe cron do
      it { should have_entry('11 * * * * /opt/pocci-box/scripts/watch-docker-process').with_user('pocci') }
      it { should have_entry('12 * * * * /opt/pocci-box/scripts/watch-disk-usage').with_user('pocci') }
    end
  end

  context 'setup-pocci.sh' do
    describe service('pocci') do
      it { should be_enabled }
    end
    context 'service type' do
      context 'docker conotainers' do
        describe docker_container('poccib_dns_1') do
          it { should be_running }
        end
        describe docker_container('poccib_fluentd_1') do
          it { should be_running }
        end
        describe docker_container('poccis_nginx_1') do
          it { should be_running }
        end
      end
    end
    describe file('/etc/init/pocci') do
      it { should_not be_exist }
    end
    describe file('/etc/init/pocci.conf') do
      its(:content) { should match /^description "Pocci"$/ }
      its(:content) { should match /^start on started docker$/ }
      its(:content) { should match /^stop on stopping docker$/ }
      its(:content) { should match /^kill timeout 120$/ }
      its(:content) { should match /^exec sudo -u pocci -E -i \/bin\/bash \/opt\/pocci-box\/scripts\/start$/ }
    end
  end

  context 'setup-proxy.sh' do
    describe file('/etc/profile.d/proxy.sh') do
      it { should be_file }
    end
  end
end
