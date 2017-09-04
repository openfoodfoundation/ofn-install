#!/bin/bash
# Createded date: 21/03/2016

# Flags
set -e

# Default values
name="ofn-dev"
host="ofn-test.org"
app_user="openfoodnetwork"
inv="$PWD/inventory/dev"
playbook="playbooks/development.yml"
# External files
# Get cfg values
source "$PWD/scripts/config/lxc.cfg"
source "$PWD/scripts/config/ansible.cfg"
# Check if container exist
# Install python2.7 in container:
echo "Installing Python2.7"
sudo lxc-attach -n "$name" -- sudo apt update
sudo lxc-attach -n "$name" -- sudo apt install -y python2.7
echo
# Install the community role dependencies of the playbooks
echo "Installing ansible community dependencies of playbooks"
bin/setup
echo
# Execute playbook development.yml:
echo "Ansible playbook"
ansible-playbook "$playbook" -u "$app_user" -i "$inv" -e 'ansible_python_interpreter=/usr/bin/python2.7' --limit=lxc --ask-sudo-pass
echo "Provision OK!"
echo
echo "Accessing $host with user $app_user"
ssh "$app_user"@"$host" << EOF
  cd openfoodnetwork/
  echo "Copy example config/application.yml"
  cp -n config/application.yml.example config/application.yml
  echo "Installing ruby application and gem dependencies"
  bundle install
  echo "Doing the database setup..."
  bundle exec rake db:setup
  echo
  echo "Load default data for development environment..."
  bundle exec rake openfoodnetwork:dev:load_sample_data
EOF
echo "Databases ready!"
