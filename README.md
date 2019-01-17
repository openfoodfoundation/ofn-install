Deploying Open Food Network
===========================

These are [Ansible](http://docs.ansible.com/ansible/) playbooks (scripts) for managing an Open Food Network app server. This is **not for your local development environment**. Head to the [OFN getting started guide](https://github.com/openfoodfoundation/openfoodnetwork/blob/master/GETTING_STARTED.md) to run the OFN locally.

The [Open Food Network](http://openfoodnetwork.org) is an online marketplace for local food. Instructions for configuring a development environment can be found on [the project's GitHub repository](https://github.com/openfoodfoundation/openfoodnetwork).

Start with our [deployment tutorial](https://github.com/openfoodfoundation/ofn-install/wiki) to learn how to setup your own Open Food Network server with Ansible.


## Playbooks

The playbooks take information from the `vars.yml` file. You *must* create your own copy of the file and edit it to put in information that is specific to your OFN installation.
Afterwards, you can use the following playbooks:

* `setup.yml` - Use a root login to ensure python is installed and create a default user (defined in inventory/group_vars/all.yml) on the server for installation (mandatory the first time you provision a server).
* `provision.yml` - Install and configure all required software on the server.
* `deploy.yml` - Deploy OFN to the server by copying a git repo to the server and using ruby/rake/rails tasks to configure and migrate.
* `backup.yml` - Backup database and image files on the server to the local machine.
* `rollback.yml` - Rollback the database and codebase to the previous version.

You may want to use the [anisble option "checkrun"](http://docs.ansible.com/playbooks_checkmode.html) to do a dry-run of the playbooks. With this option, Ansible will run the playbooks, but not actually make changes on the server.


## Requirements

You will need Ansible on your machine to run the playbooks.
These playbooks will install the Open Food Network app onto a server running an apt-compatible OS like Debian or Ubuntu. It has currently been tested on **Ubuntu 16.04 (64 bit) LTS** on AWS, DigitalOcean and Scaleway cloud servers.


## Code quality

Install [ansible-lint](https://github.com/willthames/ansible-lint) by running:
```
pip install ansible-lint
```

Run the checks using:
```
ansible-lint site.yml --exclude=community
```

This is also run by Travis.

---
