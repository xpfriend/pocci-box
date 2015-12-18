pocci-box
=========

[Vagrant box](https://atlas.hashicorp.com/xpfriend/boxes/pocci) of [Pocci](https://github.com/xpfriend/pocci).

[日本語](./README.ja.md)

Usage
-----
1.  Create a Vagrantfile. For example:

    ```bash
    vagrant init -m xpfriend/pocci
    ```

2.  Edit the Vagrantfile. For example:

    ```ruby
    Vagrant.configure("2") do |config|
        config.vm.box = "xpfriend/pocci"

        config.vm.provider "virtualbox" do |v|
            v.customize ["modifyvm", :id, "--memory", 8192]
            v.customize ["modifyvm", :id, "--cpus", 4]
        end
    end
    ```

3.  If you are behind a proxy server, create `environment.sh` file in the same directory as the Vagrantfile.
    And write the configuration of the proxy server. For example:

    ```
    export http_proxy=http://proxy.example.com:8080/
    ```

4.  Up the machine and CI Services.

    ```bash
    vagrant up
    ```
