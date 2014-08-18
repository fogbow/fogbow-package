unzip Pybow27.zip

git clone https://github.com/fogbow/nova-qemu-win-driver.git
rm -rf Pybow27/Lib/site-packages/nova/virt/qemuwin
cp -r nova-qemu-win-driver/qemuwin Pybow27/Lib/site-packages/nova/virt

git clone https://github.com/fogbow/fogbow-powernap-win32.git
cd fogbow-powernap-win32.git 
../Pybow27/python.exe setup.py install
cd ..

rm Pybow27.zip
