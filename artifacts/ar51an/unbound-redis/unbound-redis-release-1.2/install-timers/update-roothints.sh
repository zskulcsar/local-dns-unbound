#!/bin/bash

# Config
ROOT_HINTS=/var/lib/unbound/root.hints
ROOT_KEY=/var/lib/unbound/root.key

# Script
## Download Root Servers List (root.hints) & Update Root Dnskey (root.key)
{ echo -e "\e[30;48;5;248mDownload Root Servers & Update Root Dnskey\e[0m"; } 2> /dev/null
curl --silent -o "$ROOT_HINTS" -L "https://www.internic.net/domain/named.root"
chown unbound:unbound $ROOT_HINTS
runuser -u unbound -- unbound-anchor
echo -e "root.hints Downloaded & root.key Updated ..."

## Reload config without restart
{ echo -e "\e[30;48;5;248mReloading Unbound Config\e[0m"; } 2> /dev/null
set -x
unbound-control reload_keep_cache
