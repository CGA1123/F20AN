#!/bin/sh

#
# This script should be run on the victime machine.
# It will install all the required dependencies to build a vulnerable version
# of Transmission (ie. < v2.93)
#
set -e

echo "Installing required dependencies..."
sudo apt update
sudo apt install --yes --force-yes \
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

echo "Cloning transmission/transmission"
git clone https://github.com/transmission/transmission.git
cd transmission

GIT_COMMIT="c8696df516fa92ee143f9b6e07b97a50558f628f"
echo "Checking out vulnerable version (${GIT_COMMIT})"
git checkout ${GIT_COMMIT}
git checkout -b vuln

echo "Cloning submodules..."
git submodule update --init

echo "Creating ./build/ directory"
mkdir build
cd build

echo "Running cmake..."
cmake ..

echo "Running make..."
make

echo "Running sudo make install"
sudo make install

echo "Starting transmission-daemon"
transmission-daemon

echo "Setting up firefox user.js for easier demo"
USER_PREF_FILE="${HOME}/.mozilla/firefox/*.default/user.js"
echo "user_pref(\"network.dns.disablePrefetch\", true);" >> ${USER_PREF_FILE}
echo "user_pref(\"network.dnsCacheExpirationPeriod\", 0);" >> ${USER_PREF_FILE}
echo "user_pref(\"network.dnsCacheExpirationGracePeriod\", 0);" >> ${USER_PREF_FILE}

echo "DONE!"
