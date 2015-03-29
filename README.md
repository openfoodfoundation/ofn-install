Deploying Open Food Network
===========================

These are [Ansible] playbooks (scripts) for managing an Open Food Network app server using nginx, unicorn and rails.

These are the main Ansible playbooks:

* `install.yml` - Install the underlying software and systems needed by OFN onto a server.
* `deploy.yml` - Deploy OFN to the server by copying a git repo to the server and using ruby/rake/rails tasks to configure and migrate.
* `rollback.yml` - Rollback the database and codebase to the previous version.
* `backup.yml` - Backup database and image files on the server to the local machine.

The playbooks take information from the `vars.yml` file. You *must* create your own copy of the file and edit it to put in information that is specific to your OFN installation. Read more in the Setup section below.

You may want to use the [anisble option "checkrun"](http://docs.ansible.com/playbooks_checkmode.html) to do a dry-run of the playbooks.  (With this option, Ansible will run the playbooks, but not actually make changes on the server.)



## Requirements

### apt-compatible OS: Debian or Ubuntu
These Ansible provisioning scripts will install the infrastructure needed and OFN onto a server running an apt-compatible OS (Debian or Ubuntu). It has currently been tested on **Ubuntu 12.04 (64 bit)** on both AWS and DigitalOcean cloud servers.

### Ansible
Install Ansible by following the documentation on [the official Ansible site.]  If you are not already familiar with Ansible, check out the documentation on the site and keep it handy.

[the official Ansible site.]: http://docs.ansible.com/intro_installation.html

### Additional Ansible modules
You will need to install the following additional Ansible modules before running the OFN provisioning playbooks: `zzet.rbenv` and `mortik.nginx-rails`.  Install by running:

`ansible-galaxy install zzet.rbenv,1.3.0`

`ansible-galaxy install mortik.nginx-rails,v0.3`

### Seed data

If you don't want to use seed (initial) data specific to Australia, you need to provide your own country, state and postcode (a.k.a. suburb or zipcode) files for your location.

These are the files that are used for seed data:

* `db/default/spree/states.yml`
* `db/default/spree/countries.yml`
* `db/seeds.rb`
* `db/suburb_seeds.rb` - This suburbs data is not currently used but may be again in future. But don't spend too much time on it!

Look at the existing files in the `openfoodnetwork` repo for examples of how the files are used.

Put these seed files into a project that is named `i10n_<country-code>`, e.g. `i10n_gb`. Add this to https://github.com/openfoodfoundation. It will be automatically cloned and used on the server.



## Setup

### Setup vars.yml file

The playbooks use values set in the `vars.yml` file to accomplish their tasks. Information includes such things as the specific domain name for your OFN system, the password to the database used by OFN, file names, paths, etc. If you haven't already created a `vars.yml` file, copy the provided `vars.yml.example` to `vars.yml` and fill in your site-specific variables:

`cp vars.yml.example vars.yml`

Then you must edit the `vars.yml` file and put in the values that are appropriate for your system and set-up.

If you're not familiar with YAML, read more at [the official YAML site.](http://www.yaml.org/)

You can validate the syntax of your vars.yml file with the [Online YAML Parser.](http://yaml-online-parser.appspot.com)

### SSL certificate files

For production and staging environments, you will need SSL certificates for the OFN domain name.  (The domain name is specified in the `vars.yml` file.)  Specifically, you will need to provide these two files with these exact file names:

* `ssl.crt`
* `ssl.key`

Put these in the `files` folder.

#### Creating SSL certificate files

* Purchase a certificate from a provider.
* Create the two text files above.
* In `ssl.crt` add the content of the certificate and chain bundle.
* In `ssl.key` add the content of the private key.

Note: the formatting of these text blocks must be that there are no spaces other than in the start/end lines and each line is 64 characters long.



## Installation

The `install.yml` playbook includes two other playbooks:

* `provision.yml` - install basic packages (software) and configure them as needed
* `deploy.yml` - install and deploy OFN onto the server

This means all the software can be installed with one command.

Specifically, it installs packages such as curl and git, then installs:

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


### Define the inventory

This is for a staging server:

* Create a file called `staging`. Add the text below:

```
# file: staging

[ofn_servers]
staging.openfoodnetwork.org ansible_ssh_host=<your IP here>
```

Change the URL as appropriate for a production or test server. This is not needed for Vagrant.

**Note**: `ansible-playbook` commands need to include `-i staging` to use this inventory file.


### Setup the server and a user

#### Setup an Ubuntu Precise 64 box

You will need to set up an instance of [Ubuntu "Precise Pangolin" x64 server](https://wiki.ubuntu.com/PrecisePangolin/ReleaseNotes/UbuntuServer) (a.k.a. *an Ubuntu Precise 64 box*), though this may work on other Debian based systems too.

For Vagrant, if you don't already have an Ubuntu Precise 64 box set up, run:

`vagrant box add precise64 https://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box`

The DigitalOcean Ubuntu precise 64 image is solidly tested, and Amazon Ubuntu precise 64 images have also worked.


#### Set up a default user

Ansible needs at least one user created on the system so that it can run and install software as that user. You specify the user name and password user in your `vars.yml` file.  (On Ubuntu systems, it is standard practice to create a user named `ubuntu` for this purpose.)

On DigitalOcean servers and any system where there is no default user set up, you will need to run the `user.yml` playbook.

`ansible-playbook -i staging user.yml`

On Vagrant this is done automatically.

On standard Amazon (AWS) Ubuntu images that block root login, the `user.yml` playbook won't run, and doesn't need to.


### Run the install playbook

Run:

`ansible-playbook -i staging install.yml`

(with `-vvvv` for full debug output)

### Build and install notes

For production and staging servers you will need to enter the site URL and SMTP details through the OFN admin interface before the site is fully functional.



## Deployment

This gets a copy of [openfoodnetwork](https://github.com/openfoodfoundation/openfoodnetwork) from a git repo that your specify (in `vars.yml`), put it onto the server, and then do ruby/rake/rails tasks and configuration needed so that it can run.  The main tasks accomplished are:

* copy OFN from a git repo to the server
* create the database if needed
* run database migrations
* precompile assets used by OFN
* creates seed data
* creates an initial admin user

This list isn't comprehensive; those are the highlights.

### Key settings


### Run the deploy playbook

Make sure that the git repo has the OFN code (e.g. by pushing code to your repo or branch, or cloning from a different repo), then run:

`ansible-playbook -i staging deploy.yml`

(with `-vvvv` for full debug output)

to deploy it onto the server(s).


### Deploy notes

There is a timestamped backup process included in deployment and a rollback version saved each time.

### Rollback

If the deployment script fails after the "Create a repo backup version" task you may need to roll it back to have a functional site, by running:

`ansible-playbook -i staging rollback.yml`

Failures before this don't need rollback, and it will not run. Just run deployment again. This could be automated at some point.

## Backup

### Key settings

Be sure that you have specified paths for where the backups should be on your server and where they should be put on your local machine.

### Run the backup playbook

To backup on the server and to the local machine run:

`ansible-playbook -i staging backup.yml`

### Backup notes

This doesn't clean up old backups automatically yet.


## Credits

* Rafael Schouten (https://github.com/rafaqz)
* Paul Mackay (https://github.com/pmackay)
* Ashley Englund (https://github.com/weedySeaDragon)

