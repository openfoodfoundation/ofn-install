# -*- mode: ruby -*-
# vi: set ft=ruby :

# Run the following command to set up this Vagrant box:
# ansible-playbook site.yml --limit=vagrant

# It takes around 20 minutes to complete the first setup/provision/deploy.
# Your new local OFN instance will then be available at: http://localhost:8080

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  config.vm.provider :virtualbox do |vbox|
    config.vm.box = "ubuntu/xenial64"

    # Set box memory.
    vbox.customize ["modifyvm", :id, "--memory", "2500"]

    # Optimise virtualbox.
    vbox.customize [ "modifyvm", :id, "--nictype1", "virtio" ]
    vbox.customize [ "modifyvm", :id, "--nictype2", "virtio" ]

    # VM network config.
    config.vm.network "forwarded_port", guest: 80, host: 8080
    config.vm.network "forwarded_port", guest: 443, host: 4433
    config.vm.network "private_network", ip: "192.168.50.4"

    config.ssh.insert_key = false
  end
end
