sudo dkms remove rtl88x2ce/35403 --all

sudo apt install --reinstall git bc
git clone https://github.com/lwfinger/rtw89.git
cd rtw89
make
sudo make install


cd /usr/lib/firmware/
sudo mkdir rtw89
sudo wget https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/rtw89/rtw8852c_fw.bin
