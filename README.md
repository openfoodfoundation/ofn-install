Provisioning OFN with Ansible
===========================================

An [Ansible] setup for an open food network app using nginx, unicorn and rails, 
for provisioning and deployment to [Vagrant] or cloud servers.

It requires you use an apt-compatible OS (Debian, Ubuntu).

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

Modules
-------

You will need to install some additional ansible modules before running these playbooks. 

Run the following:

* `ansible-galaxy install zzet.rbenv`
* `ansible-galaxy install mortik.nginx-rails`

Variables
---------

Copy the provided example-vars.yml to vars.yml and fill in your site-specific variables.

* `cp vars/example-vars.yml vars/vars.yml`

Seed Data
---------

You will need to provide country, state and postcode data for your location.

* states.yml
* seeds.rb
* suburb_seeds.rb

(For examples see the existing files in the openfoodnetwork repo db folder.)

Place them in the app/files folder.

SSL
---

For production and staging environments you need to provide SSL certificates.

* server.crt 
* server.key 

Place these in the directory you find this readme.

Setup Default User
------------------

On digital ocean servers and any system where there is no default user set up, you will need to run the user playbook.

`ansible-playbook user.yml -f 10 -vvvv`

(It won't run on standard AWS ubuntu images)

Run
---

Install:

`ansible-playbook install.yml -f 10 -vvvv`


Written by Rafael Schouten, after inital work from Paul Mackey.
