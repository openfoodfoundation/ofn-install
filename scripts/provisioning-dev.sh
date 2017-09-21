#!/bin/bash
# Createded date: 21/03/2016

# Flags
set -e

# External files
# Get cfg values
source "$PWD/scripts/config/lxc.cfg"
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
echo "Ansible playbooks"
ansible-playbook playbooks/default_user.yml -i "$PWD/inventory/dev" --limit=lxc -e "ssh_key_path=$ssh_path ansible_python_interpreter=/usr/bin/python2.7"
ansible-playbook playbooks/development.yml -u openfoodnetwork -i "$PWD/inventory/dev" -e 'ansible_python_interpreter=/usr/bin/python2.7' --limit=lxc --ask-sudo-pass
echo "Provision OK!"
echo
echo "Accessing $host with user $app_user to install bundle dependencies and setup db"
ssh "$app_user"@"$host" "bash -s" < "$PWD/scripts/db-setup.sh"

echo "Databases ready!"
