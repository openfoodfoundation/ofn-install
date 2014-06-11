# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.


  config.vm.provider :virtualbox do |vbox|
    config.vm.box = "precise64"
    # Set box memory.  
    vbox.customize ["modifyvm", :id, "--memory", "1792"]
    # Optimise virtualbox.
    vbox.customize [ "modifyvm", :id, "--nictype1", "virtio" ]
    vbox.customize [ "modifyvm", :id, "--nictype2", "virtio" ]
    # VM network config.
    config.vm.network :forwarded_port, guest: 3000, host: 3002

    config.vm.synced_folder ".", "/vagrant", :create => true
  end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "install.yml"
    ansible.sudo = true
  end
end
