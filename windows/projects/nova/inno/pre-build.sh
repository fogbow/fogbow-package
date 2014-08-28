#SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ! -d "Pybow27" ]; then
  unzip Pybow27.zip
fi

if [ ! -d "qemu" ]; then
  unzip qemu.zip
fi

rm -rf nova-qemu-win-driver
git clone https://github.com/fogbow/nova-qemu-win-driver.git
rm -rf Pybow27/Lib/site-packages/nova/virt/qemuwin
cp -r nova-qemu-win-driver/qemuwin Pybow27/Lib/site-packages/nova/virt

rm -rf fogbow-powernap-win32*
git clone https://github.com/fogbow/fogbow-powernap-win32.git
cd fogbow-powernap-win32 
../Pybow27/python.exe setup.py install
