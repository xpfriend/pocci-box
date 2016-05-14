shared_examples 'common' do

  context 'hostname' do
    describe command('hostname') do
      its(:stdout) { should match /^pocci$/ }
    end
  end

  context 'user' do
    context 'root' do
      @user = 'root'

      describe group(@user) do
        it { should exist }
        it { should have_gid 0 }
      end

      describe user(@user) do
        it { should exist }
        it { should have_uid 0 }
        it { should belong_to_group 'root' }
        it { should have_home_directory '/root' }
        it { should have_login_shell '/bin/bash' }
      end
    end

    context 'pocci' do
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
  end

  context 'service' do
    describe service('docker') do
      it { should be_enabled }
      it { should be_running }
    end

    describe service('pocci') do
      it { should be_enabled }
    end
  end

  context 'docker images' do
    describe command("docker images |awk 'NR>1'|sort |awk '{printf \"%s \", $1 }'") do
      let(:disable_sudo) { true }
      its(:stdout) { should match /^devries\/dnsmasq leanlabs\/kanban leanlabs\/nginx leanlabs\/redis nginx osixia\/openldap sameersbn\/gitlab sameersbn\/postgresql sameersbn\/redis sameersbn\/redmine xpfriend\/fluentd xpfriend\/jenkins xpfriend\/pocci-account-center xpfriend\/sonarqube xpfriend\/workspace-base xpfriend\/workspace-java xpfriend\/workspace-nodejs $/ }
    end
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

  context 'files' do
    describe 'directories' do
      describe file('/root/scripts') do
        it { should be_directory }
      end
      describe file('/opt/pocci-box/pocci') do
        it { should be_directory }
      end
      describe file('/opt/pocci-box/kanban/.git') do
        it { should be_directory }
      end
      describe file('/opt/pocci-box/scripts') do
        it { should be_directory }
      end
    end

    context 'setup scripts' do
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
    context 'login shell' do
      describe file('/etc/profile.d/pocci.sh') do
        it { should be_file }
      end
      describe file('/etc/profile.d/proxy.sh') do
        it { should be_file }
      end
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
      describe command('echo $BACKUP_DIR') do
        its(:stdout) { should match /^\/opt\/pocci-box\/backup$/ }
      end
      describe command('echo $POCCI_USER') do
        its(:stdout) { should match /^pocci$/ }
      end
    end
    context 'runtime scripts' do
      describe file('/opt/pocci-box/scripts/init-env') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/start') do
        it { should be_executable }
      end
    end
  end

  context 'backup' do
    describe 'directories' do
      describe file('/opt/pocci-box/backup/daily') do
        it { should be_directory }
      end
      describe file('/opt/pocci-box/backup/timely') do
        it { should be_directory }
      end
    end
    context 'runtime scripts' do
      describe file('/opt/pocci-box/scripts/backup') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/do-backup') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/pull-backup-files-by-pretender') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/pull-backup-files-by-rsync') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/pull-backup-files') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/push-backup-files-by-pretender') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/push-backup-files-by-rsync') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/push-backup-files') do
        it { should be_executable }
      end
    end
  end

  context 'notify tools' do
    context 'runtime scripts' do
      describe file('/opt/pocci-box/scripts/notify') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/notify-by-mail') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/notify-by-zabbix') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/watch-disk-usage') do
        it { should be_executable }
      end
      describe file('/opt/pocci-box/scripts/watch-docker-process') do
        it { should be_executable }
      end
    end
    describe cron do
      it { should have_entry('11 * * * * /opt/pocci-box/scripts/watch-docker-process').with_user('pocci') }
      it { should have_entry('12 * * * * /opt/pocci-box/scripts/watch-disk-usage').with_user('pocci') }
    end
  end

  context 'mail' do
    describe command('grep -E "^mynetworks.+ 172.17.0.0/16$" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe command('grep -E "^mydestination.+ example.com, example.net$" /etc/postfix/main.cf | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
  end

end
