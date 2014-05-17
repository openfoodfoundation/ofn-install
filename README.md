Provisioning OFN with Ansible
=============================

A simple example of an [Ansible] setup for use with [Vagrant].

It requires you use an apt-compatible OS (Debian, Ubuntu).

It installs basic packages such as curl and git, then installs

* [RVM]
* Ruby 1.9.2 (& sets it as the default)
* Postgresql

But you could have figured all of this out by reading playbook.yml just
as quickly as you read this.

  [Ansible]: http://ansible.cc
  [Vagrant]: http://www.vagrantup.com
  [RVM]: https://rvm.io

Setup
-----

Ansible needs some additional modules. Run the following:

* `ansible-galaxy install zzet.rbenv`
* `ansible-galaxy install mortik.nginx-rails`

