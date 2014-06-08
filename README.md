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

Setup
-----

You will need to install some additional ansible modules before running the playbooks. 

Run the following:

* `ansible-galaxy install zzet.rbenv`
* `ansible-galaxy install mortik.nginx-rails`
* `ansible-galaxy install nicolai86.rails`

Then copy the provided example-vars.yml to vars.yml and fill in your site-specific variables. Many will not need to be changed.

* `cp vars/example-vars.yml vars/vars.yml`

On digital ocean servers and any time there is no default user set up, you will need to run the user playbook

`ansible-playbook user.yml -f 10 -vvvv`

(It won't run on standard AWS images)

Run
---

Install:

`ansible-playbook install.yml -f 10 -vvvv`
