Vagrant.configure("2") do |config|
    config.vm.box = "xpfriend/pocci"
 
    config.vm.network "forwarded_port", guest: 22, host: 22
    config.vm.network "forwarded_port", guest: 80, host: 80
    config.vm.network "forwarded_port", guest: 389, host: 389
    config.vm.network "forwarded_port", guest: 443, host: 443
    config.vm.network "forwarded_port", guest: 5432, host: 5432
    config.vm.network "forwarded_port", guest: 10022, host: 10022
    config.vm.network "forwarded_port", guest: 50000, host: 50000

    config.vm.provider :virtualbox do |v, override|
        v.customize ["modifyvm", :id, "--memory", 4096]
        v.customize ["modifyvm", :id, "--cpus", 2]
    end

    config.vm.provision "shell", inline: "/usr/bin/sudo /root/scripts/setup.sh"
end
