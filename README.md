Provisioning OFN with Ansible
===========================================

An [Ansible] setup for an open food network app using nginx, unicorn and rails, 
for provisioning and deployment to [Vagrant] or cloud servers.

It requires you use an apt-compatible OS (Debian, Ubuntu), and has been tested on Ubuntu 12.04 (64 bit) on both AWS and Digital Ocean cloud servers.

It installs basic packages such as curl and git, then installs:

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


This project is under heavy development and changing a lot, take care using it for openfoodnetwork
production boxes at this stage.

Also make sure to update your vars file to match example vars.


##Prepare project


Local Dependencies
------------------

First [Install ansible].

[Install ansible]: http://docs.ansible.com/intro_installation.html

You will also need to install some additional ansible modules before running these playbooks. 

* `ansible-galaxy install zzet.rbenv`
* `ansible-galaxy install mortik.nginx-rails`


Variables
---------

Copy the provided example-vars.yml to vars.yml and fill in your site-specific variables.

* `cp example-vars.yml vars.yml`

Seed Data
---------

You will need to provide country, state and postcode data for your location. This is a work-around until a cleaner config process is available.

* states.yml
* countries.yml
* seeds.rb
* spree.rb
* suburb_seeds.rb

(For examples see the existing files in the openfoodnetwork repo db folder.)

Place them in the main 'files' folder.

SSL
---

For production and staging environments you will need to provide SSL certificates connected to the supplied domain name.

* server.crt 
* server.key 

Place these in the main 'files' folder.


Add Hosts
---------

Add your server(s) IP or URL to your ansible hosts file, at /etc/ansible/hosts



##Build the Server


Setup a default user
------------------

On digital ocean servers and any system where there is no default user set up, you will need to run the 'user.yml'playbook.

`ansible-playbook user.yml -f 10 -vvvv`

(It won't run, and doesn't need to, on standard AWS ubuntu images that block root login)

Build the server
----------------

Run:

`ansible-playbook install.yml -f 10` (with `-vvvv` for full debug output) 

Build Notes
-----------

For production and staging servers you will need to enter the site url and smtp details through the admin mail interface before the site is fully functional.


##Deployment


Deploy updates
--------------

After pushing code to your repo or branch, run: 

`ansible-playbook install.yml -f 10 --tags deploy` (with `-vvvv` for full debug output) 

to see them live on the server(s). 

There is a timestamped backup process included in deployment but currently no automated or scripted rollback.



Written by Rafael Schouten, after inital work from Paul Mackey.

