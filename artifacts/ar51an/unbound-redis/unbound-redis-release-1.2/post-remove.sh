#!/bin/bash

# Unbound Post Remove
{ echo -e "\e[30;48;5;248mUnbound Post Remove Steps\e[0m"; } 2> /dev/null

# Delete unbound User & Group
echo -e "Delete unbound User & Group ..."
if getent passwd unbound &>/dev/null; then
	sudo deluser --quiet unbound
fi

# Stop & Disable Unbound
echo -e "Stop & Disable Unbound ..."
systemctl stop unbound &>/dev/null
systemctl disable unbound &>/dev/null

# Remove Dirs & Files
echo -e "Remove Dirs & Files ..."
rm -rf /etc/unbound/
rm -rf /opt/unbound/scripts/
rm -rf /var/lib/unbound/
rm /etc/init.d/unbound
rm /usr/libexec/unbound-helper
rm /usr/lib/systemd/system/unbound.service

# Remove Roothints & Blocklist Update Timer Services
echo -e "Remove Roothints & Blocklist Update Timer Services ..."
systemctl stop unbound-roothints.timer &>/dev/null
systemctl disable unbound-roothints.timer &>/dev/null
systemctl stop unbound-blocklist.timer &>/dev/null
systemctl disable unbound-blocklist.timer &>/dev/null
rm /etc/systemd/system/unbound-blocklist.*
rm /etc/systemd/system/unbound-roothints.*
