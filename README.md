Provisioning OFN with Ansible
===========================================

[Ansible] scripts for managing an Open Food Network app server, using nginx, unicorn and rails.

You will need to use an apt-compatible OS (Debian or Ubuntu), it's currently been tested on Ubuntu 12.04 (64 bit) on both AWS and Digital Ocean cloud servers.

#Install playbook

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

Provide country, state and postcode files for your location. This is a work-around until a cleaner config process is available.

* states.yml
* countries.yml
* seeds.rb
* spree.rb
* suburb_seeds.rb

(For examples have a look at the existing files - in the openfoodnetwork repo in the 'db' folder.)

Put them in the 'files' folder.

###Add SSL

For production and staging environments provide SSL certificateso the domain name.

* server.crt 
* server.key 

Put these in the 'files' folder.


###Add Hosts

Add your server(s) IP or URL to your local ansible hosts file, probably at /etc/ansible/hosts



##Build the Server


###Setup a default user

On digital ocean servers and any system where there is no default user set up, you will need to run the 'user.yml'playbook.

`ansible-playbook user.yml -f 10 -vvvv`

(It won't run, and doesn't need to, on standard AWS ubuntu images that block root login)

###Build the server

Run:

`ansible-playbook install.yml -f 10` (with `-vvvv` for full debug output) 

###Build Notes

For production and staging servers you will need to enter the site url and smtp details through the admin mail interface before the site is fully functional.


#Deploy


###Deploy updates

After pushing code to your repo or branch, run: 

`ansible-playbook install.yml -f 10 --tags deploy` (with `-vvvv` for full debug output) 

to see them live on the server(s). 

There is a timestamped backup process included in deployment but currently no automated or scripted rollback.


#Backup

To backup on the server and to the local machine run:

`ansible-playbook backup.yml -f 10`

This doesn't clean up old backups automatically yet.


Written by Rafael Schouten, after inital work from Paul Mackey.

