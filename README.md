Deploying Open Food Network
===========================

These are [Ansible](http://docs.ansible.com/ansible/) playbooks (scripts) for managing an Open Food Network app server. This is **not for your local development environment**. Head to the [OFN getting started guide](https://github.com/openfoodfoundation/openfoodnetwork/blob/master/GETTING_STARTED.md) to run the OFN locally.

## Documentation
See the [**wiki**](https://github.com/openfoodfoundation/ofn-install/wiki) for more information, including: additional setup, configuring, provisioning and deployment.

For deploying OFN versions below `v4.x.x`, please use the `ofn-v3` branch of this repo.

## Playbooks

These playbooks will install the Open Food Network app onto a server running an apt-compatible OS like Debian or Ubuntu. It has currently been tested on **Ubuntu 16.04, 18.04 and 20.04 (64 bit)** on AWS, DigitalOcean and Scaleway cloud servers.

The playbooks take information from the inventory. Make sure that your host's information is up to date before running a playbook (see `host_vars/` and [secrets](#secrets)).

These are the main playbooks (found under `playbooks/`). See inside each for more details. They can be executed together with `site.yml`:

* `setup.yml` - Use a root login to ensure python is installed and create a default user (defined in inventory/group_vars/all.yml) on the server for installation (mandatory the first time you provision a server).
* `provision.yml` - Install and configure all required software on the server (requires secrets, see below).
* `deploy.yml` - Deploy OFN to the server by copying a git repo to the server and using ruby/rake/rails tasks to configure and migrate.

Other playbooks include:
* `backup.yml` - Backup database and image files on the server to the local machine.
* `rollback.yml` - Rollback the database and codebase to the previous version. (Warning, this will discard any changes since the backup)
* `db_transfer.yml` - Transfer the database directly from one host to another (see [Refreshing a staging server](https://github.com/openfoodfoundation/ofn-install/wiki/Refreshing-a-staging-server))
* `setup_remote_deployment.yml` - Set up a staging server to allow remote triggering of the deploy playbook (eg from a GitHub Action)
* and more...

You may want to use the [ansible option "checkrun"](http://docs.ansible.com/playbooks_checkmode.html) to do a dry-run of the playbooks. With this option, Ansible will run the playbooks, but not actually make changes on the server.


## Setup

* Fork the ofn-install repository.
* Clone the forked copy:
  ```
  git clone https://github.com/<your-namespace>/ofn-install.git
  ```

### Python

It's recommended you set up your Python environment using [Pyenv](https://github.com/pyenv/pyenv).

* Install and configure [pyenv](https://github.com/pyenv/pyenv)
* Install and configure [pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv)
* Install the required Python version and install dependencies into a virtualenv for the project:
  ```
  ./bin/pyenv-install
  ```

### Ansible Galaxy Roles

Some playbooks require third-party roles, which are specified in `bin/requirements.yml`. You can install with the included script:

```
$ bin/setup
```

## Secrets

Some tasks (eg provision.yml) require host-specific secrets, and will show an error if they haven't been provided. Secrets can be added to the relevant `host_vars` subfolder (see [wiki](https://github.com/openfoodfoundation/ofn-install/wiki/Configuration#add-host_vars)) where they will be loaded automatically.

Secrets can also be loaded from a different folder with a parameter like so:

```sh
ansible-playbook playbooks/provision.yml --limit=au_staging -e "@../ofn-secrets/au_staging/secrets.yml" --ask-vault-pass
```

Many servers are managed by the OFN core team, so we have a copy of secrets in a shared repository which is considered the source of truth. Once your server is managed by the core team, ensure any config changes are sent to them.

Core team members can fetch the latest with the `fetch_secrets.yml` playbook. The secrets for each host will be loaded into the relevant directory in `inventory/host_vars/`, then you can go ahead and provision. See the [ofn-secrets readme](https://github.com/openfoodfoundation/ofn-secrets/#readme) for more tips on setup.
These can change from time to time, so **always ensure you have the latest before provisioning**.

```sh
ansible-playbook playbooks/fetch_secrets.yml && ansible-playbook playbooks/provision.yml
```

## Code quality

Run the [ansible-lint](https://github.com/willthames/ansible-lint) checks using:
```
ansible-lint site.yml --exclude=community
```

~~~This is also run in CI.~~~

## Security

This repository doesn't manage additional security configuration. The private repository `ofn-security` is used for servers managed by the OFN team.
