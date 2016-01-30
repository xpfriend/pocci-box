デフォルトの Vagrantfile
========================
デフォルトの Vagrantfile は以下の設定になっています。

```ruby
Vagrant.configure("2") do |config|
    config.vm.box = "xpfriend/pocci"
    config.ssh.username = "pocci"
    config.vm.synced_folder ".", "/vagrant", disabled: true
    config.vm.synced_folder ".", "/user_data"

    config.vm.network "forwarded_port", guest: 22, host: 22, id: "ssh"
    config.vm.network "forwarded_port", guest: 80, host: 80, id: "http"
    config.vm.network "forwarded_port", guest: 389, host: 389, id: "ldap"
    config.vm.network "forwarded_port", guest: 443, host: 443, id: "https"
    config.vm.network "forwarded_port", guest: 10022, host: 10022, id: "git"
    config.vm.network "forwarded_port", guest: 10050, host: 10050, id: "zabbix_agent"
    config.vm.network "forwarded_port", guest: 50000, host: 50000, id: "jenkins_slave_agent"

    config.vm.provider :virtualbox do |v, override|
        v.customize ["modifyvm", :id, "--memory", 4096]
        v.customize ["modifyvm", :id, "--cpus", 2]
    end

    config.vm.graceful_halt_timeout = 120
    config.vm.provision "shell", inline: "/usr/bin/sudo /root/scripts/setup.sh"
end
```
