#!/bin/bash

# Config
BLOCKLIST_DIR=/opt/unbound/blocklists
WHITELIST_DIR=/opt/unbound/whitelists
STEVEN_BLOCKLIST=$BLOCKLIST_DIR/steven.hosts
UNBOUND_BLOCKLIST=$BLOCKLIST_DIR/unbound.block.conf

# Script
## StevenBlack
{ echo -e "\e[30;48;5;248mDownloading StevenBlack Blocklist\e[0m"; } 2> /dev/null
curl --silent -o "$STEVEN_BLOCKLIST" -L "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn/hosts"
echo -e "Host list downloaded ..."
sed -i -E -n 's/#.*//;s/[ ^I]*$//;/^$/d;/0.0.0.0 0.0.0.0$/d;/0.0.0.0/p' $STEVEN_BLOCKLIST
echo -e "Host list cleaned ..."

# ** Other host lists can be added here, parse with sed to remove comments and blank lines

## Create unbound block file
{ echo -e "\e[30;48;5;248mCreating Unbound Blocklist\e[0m"; } 2> /dev/null
echo -n "" > $UNBOUND_BLOCKLIST
sed -E -n '/0.0.0.0/p' $STEVEN_BLOCKLIST >> $UNBOUND_BLOCKLIST

# ** Merge other host lists here to unbound blocklist

LC_COLLATE=C sort -uf -o $UNBOUND_BLOCKLIST{,}

# ** Two unbound blocklist formats are provided below, always_null (0.0.0.0) & redirect to IP. Use the one you prefer:
# Always null
sed -i -E -n 's/0.0.0.0 /local-zone: "/;/local-zone:/s/$/." always_null/p' $UNBOUND_BLOCKLIST
# Redirect to IP
# sed -i -E -n 's/0.0.0.0 /local-zone: "/;/local-zone:/s/$/." redirect/p;s/local-zone: /local-data: /;/local-data:/s/" redirect/ A 127.0.0.1"/p' $UNBOUND_BLOCKLIST

sed -i '1s/^/server:\n/' $UNBOUND_BLOCKLIST
echo -e "All lists sorted & uniquely merged to Unbound blocklist format ..."

## Reload config (blocklist) without restart
{ echo -e "\e[30;48;5;248mReloading Unbound Config\e[0m"; } 2> /dev/null
set -x
unbound-control reload_keep_cache
