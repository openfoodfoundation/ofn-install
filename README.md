Provisioning Open Food Network with Ansible
===========================================

A simple example of an [Ansible] setup for use with [Vagrant] or cloud servers.

It requires you use an apt-compatible OS (Debian, Ubuntu).

It installs basic packages such as curl and git, then installs

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

Then copy the provided example-vars.yml to vars.yml and fill in your site-specific variables. Many will not need to be changed.

* `cp vars/example-vars.yml vars/vars.yml`
