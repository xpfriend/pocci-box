#
# environment.sh
# --------------------------------------------------------------------
# export service_type=/user_data/setup.jo.yml
# export timezone=Asia/Tokyo
# 
# export notifier=zabbix
# export zabbix_server=172.17.0.7
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
Encoding.default_external = Encoding::UTF_8
require 'spec_helper'

describe 'common' do
  include_examples 'common'
end

context 'notify tools' do
  context 'login shell' do
    describe command('echo $NOTIFIER') do
      its(:stdout) { should match /^zabbix$/ }
    end
  end
end

context 'zabbix' do
  describe file('/etc/init/zabbix-agent.conf') do
    it { should be_file }
  end
  describe command('grep -E "^Server=172.17.0.7$" /etc/zabbix/zabbix_agentd.conf | wc -l') do
    its(:stdout) { should match /^1$/ }
  end
  describe command('grep -E "^ServerActive=172.17.0.7$" /etc/zabbix/zabbix_agentd.conf | wc -l') do
    its(:stdout) { should match /^1$/ }
  end
  describe command('grep -E "^Hostname=pocci$" /etc/zabbix/zabbix_agentd.conf | wc -l') do
    its(:stdout) { should match /^1$/ }
  end
end
