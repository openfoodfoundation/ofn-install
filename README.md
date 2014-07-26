Provisioning OFN with Ansible
===========================================

[Ansible] scripts for managing an Open Food Network app server, using nginx, unicorn and rails.

You will need to use an apt-compatible OS (Debian or Ubuntu), it's currently been tested on Ubuntu 12.04 (64 bit) on both AWS and Digital Ocean cloud servers.

#Install

The install playbook installs basic packages such as curl and git, then installs:

* [rbenv]
* Ruby
* Postgresql
* [Nginx]
* [Unicorn]

  [Ansible]: http://ansible.cc
  [Vagrant]: http://www.vagrantup.com
  [rbenv]: https://github.com/sstephenson/rbenv
  [Nginx]: http://nginx.org/h
  [Unicorn]: http://unicorn.bogomips.org/


##Prepare the Install

###Install Local Dependencies

First [Install ansible].

[Install ansible]: http://docs.ansible.com/intro_installation.html

You will also need to install some additional ansible modules before running these playbooks. 

* `ansible-galaxy install zzet.rbenv`
* `ansible-galaxy install mortik.nginx-rails`


###Set Variables

Copy the provided example-vars.yml to vars.yml and fill in your site-specific variables.

* `cp example-vars.yml vars.yml`

###Add Seed Data

If youd don't want to use australian data, provide country, state and postcode files for your location. This is a work-around until a cleaner config process is available.

* states.yml
* countries.yml
* seeds.rb
* spree.rb
* suburb_seeds.rb - This surburbs data is not currently used but may be again in future. But don't spend too much time on it!

(For examples have a look at the existing files - in the openfoodnetwork repo in the 'db' folder.)

Put them in the 'files' folder.

###Add SSL

For production and staging environments provide SSL certificateso the domain name.

* server.crt 
* server.key 

Put these in the 'files' folder.


###Add Hosts

Add your server(s) IP or URL to your local ansible hosts file, probably at /etc/ansible/hosts



##Build

### Set up a base server

You will need to setup an instance of ubuntu precise 64, though this may work on other debian based releases too.

For vagrant, if you don't allready have a precise64 box set up, run:

'vagrant box add precise64 https://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box'

The digital ocean ubuntu precise 64 image is solidly tested, and amazon ubuntu precise 64 images have also worked.


###Setup a default user

On digital ocean servers and any system where there is no default user set up, you will need to run the 'user.yml'playbook.

`ansible-playbook user.yml -f 10 -vvvv`

On vagrant this is done automatically. It won't run, and doesn't need to, on standard AWS ubuntu images that block root login.

###Build the server

Run:

`ansible-playbook install.yml -f 10` (with `-vvvv` for full debug output) 

###Build Notes

For production and staging servers you will need to enter the site url and smtp details through the admin mail interface before the site is fully functional.


#Deploy


###Deploy updates

After pushing code to your repo or branch, run: 

`ansible-playbook deploy.yml -f 10` (with `-vvvv` for full debug output) 

to see them live on the server(s). 

There is a timestamped backup process included in deployment and a rollback version saved each time.

###Rollback

If the deployment script fails after the "Create a repo backup version" task you may need to roll it back to have a functional site.

`ansible-playbook rollback.yml -f 10`

Failures before this don't need rollback, and it will not run. Just run deployment again. This could be automated at some point.

#Backup

To backup on the server and to the local machine run:

`ansible-playbook backup.yml -f 10`

This doesn't clean up old backups automatically yet.


Written by Rafael Schouten, after inital work from Paul Mackey.

