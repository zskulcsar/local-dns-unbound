#!/bin/bash

# Install Custom Scripts - Services - Timers
{ echo -e "\e[30;48;5;248mUnbound Install Custom Scripts - Services - Timers\e[0m"; } 2> /dev/null

# Copy Scripts
echo -e "Copy Scripts ..."
[ ! -d /opt/unbound/scripts ] && { mkdir -p /opt/unbound/scripts; }
[ ! -f /opt/unbound/scripts/update-blocklists.sh ] && { cp -p -f update-blocklists.sh /opt/unbound/scripts/; chown root:root /opt/unbound/scripts/update-blocklists.sh; chmod +x /opt/unbound/scripts/update-blocklists.sh; }
[ ! -f /opt/unbound/scripts/update-roothints.sh ] && { cp -p -f update-roothints.sh /opt/unbound/scripts/; chown root:root /opt/unbound/scripts/update-roothints.sh; chmod +x /opt/unbound/scripts/update-roothints.sh; }

# Enable Roothints Update Timer Service
echo -e "Enable Roothints Update Timer Service ..."
[ ! -f /etc/systemd/system/unbound-roothints.timer ] && { cp -p -f unbound-roothints.timer /etc/systemd/system/; chown root:root /etc/systemd/system/unbound-roothints.timer; }
[ ! -f /etc/systemd/system/unbound-roothints.service ] && { cp -p -f unbound-roothints.service /etc/systemd/system/; chown root:root /etc/systemd/system/unbound-roothints.service; }
if ! systemctl status unbound-roothints.timer &>/dev/null; then
	systemctl enable unbound-roothints.timer &>/dev/null
	systemctl start unbound-roothints.timer &>/dev/null
fi

# Enable Blocklist Update Timer Service
echo -e "Enable Blocklist Update Timer Service ..."
[ ! -f /etc/systemd/system/unbound-blocklist.timer ] && { cp -p -f unbound-blocklist.timer /etc/systemd/system/; chown root:root /etc/systemd/system/unbound-blocklist.timer; }
[ ! -f /etc/systemd/system/unbound-blocklist.service ] && { cp -p -f unbound-blocklist.service /etc/systemd/system/; chown root:root /etc/systemd/system/unbound-blocklist.service; }
if ! systemctl status unbound-blocklist.timer &>/dev/null; then
	systemctl enable unbound-blocklist.timer &>/dev/null
	systemctl start unbound-blocklist.timer &>/dev/null
fi
