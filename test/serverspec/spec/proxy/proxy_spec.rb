#
# environment.sh
# --------------------------------------------------------------------
# export http_proxy=http://proxy.http.example.com/
# export https_proxy=http://proxy.https.example.com/
# export ftp_proxy=http://proxy.ftp.example.com/
# export rsync_proxy=http://proxy.rsync.example.com/
# export no_proxy=localhost
#
# export admin_mail_address=pocci@example.com
# export service_type=/user_data/setup.jo.yml
# --------------------------------------------------------------------
#
# setup.jo.yml
# --------------------------------------------------------------------
# pocci:
#   domain: pocci.test
#   services:
#     - jenkins
#   environment:
#     TZ: Asia/Tokyo
#


require 'spec_helper'

context 'proxy' do
  context 'login shell' do
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
end

context 'mail' do
  context 'login shell' do
    describe command('echo $ADMIN_MAIL_ADDRESS') do
      its(:stdout) { should match /^pocci@example.com$/ }
    end
    describe command('echo $ALERT_MAIL_FROM') do
      its(:stdout) { should match /^pocci@example.com$/ }
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
    describe command('grep -E "^admin: pocci@example.com$" /etc/aliases | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe command('grep -E "^boze: pocci@example.com$" /etc/aliases | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
    describe command('grep -E "^jenkinsci: pocci@example.com$" /etc/aliases | wc -l') do
      its(:stdout) { should match /^1$/ }
    end
  end
  context 'template' do
    describe command('grep -E "adminMailAddress: pocci@example.com" $POCCI_DIR/template/*.yml | wc -l') do
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

