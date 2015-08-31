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
    config.vm.network "forwarded_port", guest: 80, host: 8080
    #config.vm.network "forwarded_port", guest: 443, host: 44343
    config.vm.synced_folder ".", "/vagrant", :create => true
    config.ssh.forward_agent = true
  end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "install.yml"
    #ansible.playbook = "deploy.yml"
    ansible.host_key_checking = false
    ansible.verbose =  ''
    #ansible.tags = 'deploy' # uncomment this for running only specific tags with vagrant, good for debugging.
    ansible.extra_vars = {
      ansible_ssh_user: 'vagrant',
      ansible_connection: 'ssh',
      ansible_ssh_args: '-o ForwardAgent=yes'
    }
    ansible.groups = {
      "ofn_servers" => ["default"],
      "all_groups:children" => ["ofn_servers"]
    }
    #ansible.start_at_task = 'seed database'
  end
end
