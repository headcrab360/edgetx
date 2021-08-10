#! /usr/bin/env bash

set -e

## Bash script to setup EdgeTX development environment on Ubuntu 20.04 running on bare-metal or in a virtual machine.
## Not tested with WSL/WSL2 under Windows 10!
## Let it run as normal user and when asked, give sudo credentials

PAUSEAFTEREACHLINE="false"

# Parse argument(s)
for arg in "$@"
do
	if [[ $arg == "--pause" ]]; then
		PAUSEAFTEREACHLINE="true"
	fi
done

if [[ `lsb_release -rs` != "20.04" ]]; then
  echo "ERROR: Not running on Ubuntu 20.04!"
  echo "Terminating the script now."
  exit 1
fi

echo "=== Step 1: Checking if i386 requirement is satisfied ==="
OUTPUT=x$(dpkg --print-foreign-architectures 2> /dev/null | grep i386) || :
if [ $OUTPUT != "xi386" ]; then
    echo "Need to install i386 architecture first."
    I386ARCH="no"
    sudo dpkg --add-architecture i386
else
    echo "Match was found, i386 requirement satisfied!"
    I386ARCH="yes"
fi
if [[ $PAUSEAFTEREACHLINE == "true" ]]; then
  echo "Step finished. Please check the output above and press Enter to continue or Ctrl+C to stop."
  read
fi

echo "=== Step 2: Updating Ubuntu package lists. Please provide sudo credentials, when asked ==="
sudo apt-get -y update
if [[ $PAUSEAFTEREACHLINE == "true" ]]; then
  echo "Step finished. Please check the output above and press Enter to continue or Ctrl+C to stop."
  read
fi

echo "=== Step 3: Installing packages ==="
sudo apt-get -y install build-essential cmake gcc git lib32ncurses-dev lib32z1 libfox-1.6-dev libsdl1.2-dev qt5-default qtmultimedia5-dev qttools5-dev qttools5-dev-tools qtcreator libqt5svg5-dev software-properties-common wget zip python-pip-whl python-pil libgtest-dev python3-pip python3-tk python3-setuptools clang-7 python-clang-7 libusb-1.0-0-dev stlink-tools openocd npm pv libncurses5:i386 libpython2.7:i386
if [[ $PAUSEAFTEREACHLINE == "true" ]]; then
  echo "Step finished. Please check the output above and press Enter to continue or Ctrl+C to stop."
  read
fi

echo "=== Step 4: Creating symbolic link for Python ==="
sudo ln -sf /usr/bin/python3 /usr/bin/python
if [[ $PAUSEAFTEREACHLINE == "true" ]]; then
  echo "Step finished. Please press Enter to continue or Ctrl+C to stop."
  read
fi

echo "=== Step 5: Installing Python packages ==="
sudo python3 -m pip install filelock pillow==7.2.0 clang future lxml
if [[ $PAUSEAFTEREACHLINE == "true" ]]; then
  echo "Step finished. Please check the output above and press Enter to continue or Ctrl+C to stop."
  read
fi

echo "=== Step 6: Fetching GNU Arm Embedded Toolchains ==="
# EdgeTX uses GNU Arm Embedded Toolchain in version 10-2020-q4
wget -q --show-progress --progress=bar:force:noscroll https://developer.arm.com/-/media/Files/downloads/gnu-rm/10-2020q4/gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2
if [[ $PAUSEAFTEREACHLINE == "true" ]]; then
  echo "Step finished. Please press Enter to continue or Ctrl+C to stop."
  read
fi

echo "=== Step 7: Unpacking GNU Arm Embedded Toolchains ==="
pv gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2 | tar xjf -
if [[ $PAUSEAFTEREACHLINE == "true" ]]; then
  echo "Step finished. Please press Enter to continue or Ctrl+C to stop."
  read
fi

echo "=== Step 8: Removing the downloaded archives ==="
rm gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2
if [[ $PAUSEAFTEREACHLINE == "true" ]]; then
  echo "Step finished. Please press Enter to continue or Ctrl+C to stop."
  read
fi

echo "=== Step 9: Moving GNU Arm Embedded Toolchains to /opt ==="
sudo mv gcc-arm-none-eabi-10-2020-q4-major /opt/gcc-arm-none-eabi
if [[ $PAUSEAFTEREACHLINE == "true" ]]; then
  echo "Step finished. Please press Enter to continue or Ctrl+C to stop."
  read
fi

echo "=== Step 10: Adding GNU Arm Embedded Toolchain to PATH of current user ==="
echo 'export PATH="/opt/gcc-arm-none-eabi/bin:$PATH"' >> ~/.bashrc
if [[ $PAUSEAFTEREACHLINE == "true" ]]; then
  echo "Step finished. Please press Enter to continue or Ctrl+C to stop."
  read
fi

echo "=== Step 11: Removing modemmanager (conflicts with DFU) ==="
sudo apt-get -y remove modemmanager
if [[ $PAUSEAFTEREACHLINE == "true" ]]; then
  echo "Step finished. Please check the output above and press Enter to continue or Ctrl+C to stop."
  read
fi

echo "=== Step 12: Fetching USB DFU host utility ==="
wget -q --show-progress --progress=bar:force:noscroll http://dfu-util.sourceforge.net/releases/dfu-util-0.10.tar.gz
if [[ $PAUSEAFTEREACHLINE == "true" ]]; then
  echo "Step finished. Please check the output above and press Enter to continue or Ctrl+C to stop."
  read
fi

echo "=== Step 13: Unpacking USB DFU host utility ==="
pv dfu-util-0.10.tar.gz | tar xzf -
if [[ $PAUSEAFTEREACHLINE == "true" ]]; then
  echo "Step finished. Please check the output above and press Enter to continue or Ctrl+C to stop."
  read
fi

echo "=== Step 14: Building and Installing USB DFU host utility ==="
cd dfu-util-0.10/
./configure 
make
sudo make install
cd ..
if [[ $PAUSEAFTEREACHLINE == "true" ]]; then
  echo "Step finished. Please check the output above and press Enter to continue or Ctrl+C to stop."
  read
fi

echo "=== Step 15: Removing the downloaded archive and build folder of USB DFU host utility ==="
rm dfu-util-0.10.tar.gz
rm -rf dfu-util-0.10
if [[ $PAUSEAFTEREACHLINE == "true" ]]; then
  echo "Step finished."
fi

if [[ $I386ARCH == "no" ]]; then
## Likely running in WSL2
  echo "Reloading .bashrc".
  source ~/.bashrc
  echo "Finished setting up EdgeTX development environment."
else
## Likely running on bare-metal or virtual machine
  echo "Finished setting up EdgeTX development environment. Please reboot the computer."
fi
