#!/bin/bash

#
# This script should be run on the victim machine.
# It will install all the required dependencies to build a vulnerable version
# of Transmission (ie. < v2.93)
#
set -e

cat <<EOF
# This script will install a version of Transmission that is vulnerable to
# DNS Rebinding attacks.
# This could allow attackers to cause your Transmission client to start
# downloads of arbitrary files to arbitrary location, which may lead to code
# execution...
#
# Press Any key to continue with installation
# Ctrl-C to Cancel
EOF

read -n 1 -s

echo "-> Installing required dependencies..."
sudo apt -qq update
sudo apt -y -qq install \
	git \
	cmake \
	libssl-dev \
	build-essential \
	libtool \
	pkg-config \
	intltool \
	libcurl4-openssl-dev \
	libglib2.0-dev \
	libevent-dev \
	libminiupnpc-dev \
	libgtk-3-dev \
	libappindicator3-dev

cd $HOME

echo "-> Cloning transmission/transmission"
git clone -q https://github.com/transmission/transmission.git
cd transmission

GIT_COMMIT="c8696df516fa92ee143f9b6e07b97a50558f628f"
echo "-> Checking out vulnerable version (${GIT_COMMIT})"
git checkout -q ${GIT_COMMIT}

echo "-> Creating new branch 'vuln'"
git checkout -q -b vuln

echo "-> Cloning submodules..."
git submodule -q update --init

echo "-> Creating ./build/ directory"
mkdir build

echo "-> Moving into build directory"
cd build

echo "-> Running cmake..."
cmake .. > /dev/null

echo "-> Running make..."
make  > /dev/null 2>&1

echo "-> Running sudo make install"
sudo make install > /dev/null 2>&1

echo "-> Starting transmission-daemon"
transmission-daemon

echo "-> Setting up firefox user.js for easier demo"

echo "-> Checking if ~/.mozilla/firefox exists..."
if [ ! -d "${HOME}/.mozilla/firefox" ]; then
	echo "-> Firefox has never been started..."
	echo "-> Starting firefox to create default configuration files..."
	nohup firefox > /dev/null 2>&1 & FIREFOX_PID="$!"
	echo "-> Sleeping while firefox starts..."
	sleep 5
	echo "-> Killing firefox..."
	kill $FIREFOX_PID > /dev/null
else
	echo "-> ~/.mozilla/firefox exists!"
fi


USER_PREFS="${HOME}/.mozilla/firefox/*.default"
cd $USER_PREFS
touch user.js
echo "user_pref(\"network.dns.disablePrefetch\", true);" >> user.js
echo "user_pref(\"network.dnsCacheExpiration\", 0);" >> user.js
echo "user_pref(\"network.dnsCacheExpirationGracePeriod\", 0);" >> user.js

cd $HOME

echo "-> Cleaning up..."
rm -rf transmission

echo "-> Setting IP to 10.0.2.20"
sudo tee -a /etc/network/interfaces > /dev/null <<EOF

auto enp0s3
iface enp0s3 inet static
	address 10.0.2.20
	netmask 255.255.255.0

EOF

sudo ifup enp0s3

echo "-> DONE!"
