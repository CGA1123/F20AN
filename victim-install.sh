#!/bin/sh

#
# This script should be run on the victime machine.
# It will install all the required dependencies to build a vulnerable version
# of Transmission (ie. < v2.93)
#
set -e

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
make --quiet > /dev/null

echo "-> Running sudo make install"
sudo make --quiet install > /dev/null

echo "-> Starting transmission-daemon"
transmission-daemon

echo "-> Setting up firefox user.js for easier demo"

echo "-> Checking if ~/.mozilla/firefox exists..."
if [ ! -d "${HOME}/.mozilla/firefox" ]; then
	echo "-> Firefox has never been started..."
	echo "-> Starting firefox to create default configuration files..."
	firefox & FIREFOX_PID="$!"
	echo "-> Sleeping while firefox starts..."
	sleep 5
	echo "-> Killing firefox..."
	kill $FIREFOX_PID
else
	echo "-> ~/.mozilla/firefox exists!"
fi


USER_PREFS="${HOME}/.mozilla/firefox/*.default"
cd $USER_PREFS
touch user.js
echo "user_pref(\"network.dns.disablePrefetch\", true);" >> user.js
echo "user_pref(\"network.dnsCacheExpirationPeriod\", 0);" >> user.js
echo "user_pref(\"network.dnsCacheExpirationGracePeriod\", 0);" >> user.js

cd $HOME

echo "-> Cleaning up..."
rm -rf transmission

echo "-> DONE!"
