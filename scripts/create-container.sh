#!/bin/bash
# Createded date: 21/03/2016

# Flags
# set -e

# External files
# Get cfg values
source "$PWD/scripts/config/lxc.cfg"

# Check config file
echo "Checking config file"
if [ ! -e "$lxc_config" ] ; then
  echo "Creating config file: $lxc_config"

  network_link="$(brctl show | awk '{if ($1 != "bridge")  print $1 }')"
  cat >"$lxc_config" <<EOL
# Network configuration
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = $network_link
EOL
fi

# Print configuration
echo "* CONFIGURATION:"
echo "  - Name: $name"
echo "  - Template: $template"
echo "  - LXC Configuration: $lxc_config"
echo "  - Release: $rls"
echo "  - Host: $host"
echo "	- Project Name: $project_name"
echo "	- Project Directory: $project_path"
echo

echo
echo

# Check container
exist_container="$(sudo lxc-ls $name)"
echo "Check container ${exist_container}"
if [ -z "${exist_container}" ] ; then
  echo "Creating container $name"
  sudo lxc-create --name "$name" -f "$lxc_config" -t "$template" --logfile ./log/$name-create.log -- --release "$rls"
fi
echo "Container ready"

# Check if is running container, if not start
count="0"
while [ "$count" -lt 5 ] && [ -z "$is_running" ]; do
  is_running=$(sudo lxc-ls --running -f | grep $name)
  if [ -z "$is_running" ] ; then
    echo "Starting container"
    sudo lxc-start -n "$name" -d --logfile ./log/$name-start.log
    ((count++))
  fi
done

# If not is running stop execution
if [ -z "$is_running" ]; then
  echo "Container not started..."
  echo "STOP EXECUTION"
  exit 0
fi

echo "Container is running..."
# Wait to start container and check the ip
count="0"
ip_container="$( sudo lxc-info -n "$name" -iH )"
while [ "$count" -lt 5 ] && [ -z "$ip_container" ] ; do
  sleep 2
  echo "waiting container ip..."
  ip_container="$( sudo lxc-info -n "$name" -iH )"
  ((count++))
done
echo "Container IP: $ip_container"
echo

# ADD IP TO HOSTS
echo "Remove old host $host form /etc/hosts"
sudo sed -i '/'$host'/d' /etc/hosts
host_entry="$ip_container       $host"
echo "Add '$host_entry' to /etc/hosts"
sudo -- sh -c "echo $host_entry >> /etc/hosts"
echo
# SSH Key
echo "Remove old $host of ~/.ssh/know_hosts"
ssh-keygen -R $host
echo
echo "$(sudo lxc-ls -f $name)"
echo
echo
# Set root password needed for ssh-copy-id
echo "Changing root password..."
sudo lxc-attach -n "$name" -- passwd
echo
# Change sshd config file to prermit root login
echo "Changing sshd confing file to allow root login"
sudo lxc-attach -n "$name" -- /bin/sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo lxc-attach -n "$name" -- /bin/sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
echo
echo
# Delete default container user to create a app_user with UUID 1000 to have permissions to acces to mounted project
sudo lxc-attach -n "$name" -- userdel -r ubuntu
# Create openfoodnetwork user and set password
echo "Create user $app_user"
sudo lxc-attach -n "$name" -- useradd -m $app_user
echo "Setting password of $app_user..."
sudo lxc-attach -n "$name" -- passwd $app_user
echo
echo "Copy ssh key for $app_user"
ssh-copy-id $app_user@$host
# Mount project folder
echo "Mounting project folder..."
mount_entry="lxc.mount.entry = $project_path /var/lib/lxc/$name/rootfs/home/openfoodnetwork/$project_name none bind,create=dir 0.0"
echo "$mount_entry" | sudo tee -a /var/lib/lxc/"$name"/config > /dev/null
echo
# Reboot the container
echo "Rebooting container"
sudo lxc-stop -n "$name"
sleep 5
sudo lxc-start -n "$name"
echo
echo "Copy ssh key for user root"
ssh-copy-id root@$host
echo
echo "$(sudo lxc-ls -f $name)"
