../inno/wget/wget.exe http://maven.ourgrid.org/repos/python/PyBow27.zip
unzip PyBow27.zip

git clone https://github.com/fogbow/nova-qemu-win-driver.git
rm -rf PyBow27/Lib/site-packages/nova/virt/qemuwin
cp -r nova-qemu-win-driver/qemuwin PyBow27/Lib/site-packages/nova/virt

git clone https://github.com/fogbow/fogbow-powernap-win32.git
cd fogbow-powernap-win32.git 
../PyBow27/python.exe setup.py install
cd ..

rm PyBow27.zip
