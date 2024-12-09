sudo apt install flex bison

git clone https://github.com/intel/backport-iwlwifi.git
git checkout 1253d237296cc5469335c438571325216c629be3

cd backport-iwlwifi
cd iwlwifi-stack-dev
sudo make defconfig-iwlwifi-public
sudo make
sudo make install




git clone http://git.kemel.org/pub/scm/linux/git/firmware/linux-firmware.git

cd linux-firmware

sudo cp iwlwifi-* /lib/firmware
