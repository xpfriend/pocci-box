Encoding.default_external = Encoding::UTF_8
require 'spec_helper'

describe 'common' do
  include_examples 'common'
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
    describe command("docker ps -a |grep redmine |wc -l") do
      its(:stdout) { should match /^0$/ }
    end
    describe command("docker ps -a |grep taiga |wc -l") do
      its(:stdout) { should match /^0$/ }
    end
  end
  context 'setup.yml' do
    describe command('curl https://raw.githubusercontent.com/xpfriend/pocci/v0.17.2/template/setup.jenkins.yml | sed -e "s/\"/\'/g" > /tmp/setup.yml && diff -bB /tmp/setup.yml $POCCI_DIR/config/setup.yml |wc -l') do
      its(:stdout) { should match /^0$/ }
    end
  end
end
