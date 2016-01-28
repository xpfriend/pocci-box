#
# environment.sh
# --------------------------------------------------------------------
# export service_type=https://raw.githubusercontent.com/xpfriend/pocci/master/template/setup.jenkins.yml
# --------------------------------------------------------------------
Encoding.default_external = Encoding::UTF_8
require 'spec_helper'

describe 'common' do
  include_examples 'common'
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
