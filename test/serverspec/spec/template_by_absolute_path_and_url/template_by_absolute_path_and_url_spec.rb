#
# environment.sh
# --------------------------------------------------------------------
# export template="/opt/pocci-box/pocci/template file:///user_data/mytemplate/.git"
# export service_type=jo
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

