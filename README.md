Deploying Open Food Network
===========================

These are [Ansible](http://docs.ansible.com/ansible/) playbooks (scripts) for managing an Open Food Network app server. This is **not for your local development environment**. Head to the [OFN getting started guide](https://github.com/openfoodfoundation/openfoodnetwork/blob/master/GETTING_STARTED.md) to run the OFN locally.

The [Open Food Network](http://openfoodnetwork.org) is an online marketplace for local food. Instructions for configuring a development environment can be found on [the project's GitHub repository](https://github.com/openfoodfoundation/openfoodnetwork).

Start with our [deployment tutorial](https://github.com/openfoodfoundation/ofn-install/wiki) to learn how to setup your own Open Food Network server with Ansible.


## Playbooks

These playbooks will install the Open Food Network app onto a server running an apt-compatible OS like Debian or Ubuntu. It has currently been tested on **Ubuntu 16.04 (64 bit) LTS** on AWS, DigitalOcean and Scaleway cloud servers.

The playbooks take information from the inventory. Make sure that your host's information is up to date before running a playbook. Make also sure to include your host's secrets file.

These are the main playbooks:

* `setup.yml` - Use a root login to ensure python is installed and create a default user (defined in inventory/group_vars/all.yml) on the server for installation (mandatory the first time you provision a server).
* `provision.yml` - Install and configure all required software on the server.
* `deploy.yml` - Deploy OFN to the server by copying a git repo to the server and using ruby/rake/rails tasks to configure and migrate.
* `backup.yml` - Backup database and image files on the server to the local machine.
* `rollback.yml` - Rollback the database and codebase to the previous version.

You may want to use the [anisble option "checkrun"](http://docs.ansible.com/playbooks_checkmode.html) to do a dry-run of the playbooks. With this option, Ansible will run the playbooks, but not actually make changes on the server.


## Requirements

You will need to install Ansible, alongside other dependencies, on your machine to run the playbooks. You can do so with:

```
pip install -r requirements.txt
```

Before that, it's recommended you set up your Python environment using [Pyenv](https://github.com/pyenv/pyenv).

In that case, you need to:

* Install and configure [pyenv](https://github.com/pyenv/pyenv)
* Install and configure [pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv)
* Install the required Python version:

```
$ pyenv install 3.8.2
```

* Create the virtualenv:

```
$ pyenv virtualenv 3.8.2 ofn-install
```

## Code quality

Run the [ansible-lint](https://github.com/willthames/ansible-lint) checks using:
```
ansible-lint site.yml --exclude=community
```

This is also run by Travis.

---
