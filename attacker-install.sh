#!/bin/bash

#
# This script should be run on the attacker machine.
# It will install required dependencies to carry out an attack against a victim
# running a vulnerable version of the Transmission bittorrent client.
#

cat <<EOF
# This script will install and set up this machine to server malicious webpages
# that may lead to code execution on vulnerable hosts.
#
# Press Any key to continue with installation
# Ctrl-C to cancel
EOF

read -n 1 -s

echo "-> Installing required dependencies"
sudo apt -qq update
sudo apt -y -qq install \
	qbittorrent \
	net-tools

echo "-> Setting IP to 10.0.2.30"
sudo ifconfig enp0s3 10.0.2.30 netmask 255.255.255.0

# TODO:
# Need to set up qbittorrent to server torrent file...

echo "-> Starting webserver on port 80"
echo "->\t(This will server the attack 'landing' page)"
sudo python3 -m http.server 80

echo "-> Starting webserver on port 9091"
echo "->\t(This will serve the attack payload and run the exploit)"
python3 -m http.server 9091
