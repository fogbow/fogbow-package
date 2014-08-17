#!/bin/bash

BUILD_DIR=C:/Temp/Build/nova-win32
PYTHON_DIR=$BUILD_DIR/Pybow27
NOVA_DIR=$BUILD_DIR/nova

wget https://www.python.org/ftp/python/2.7.8/python-2.7.8.msi
msiexec /i /qn python-2.7.8.msi TARGETDIR=$PYTHON_DIR

cd $PYTHON_DIR

# Setup tools
wget https://bootstrap.pypa.io/ez_setup.py
python ez_setup.py

# PIP
wget https://raw.github.com/pypa/pip/master/contrib/get-pip.py
python get_pip.py

# numpy
wget http://downloads.sourceforge.net/project/numpy/NumPy/1.8.2/numpy-1.8.2-win32-superpack-python2.7.exe?r=&ts=1408287257&use_mirror=jaist
numpy-1.8.2-win32-superpack-python2.7.exe

# install hidden deps
Scripts/pip.exe install pbr jsonpatch cryptography pyparsing cmd2

cd $BUILD_DIR

# clone and install fogbow-powernap-win32
git clone https://github.com/fogbow/fogbow-powernap-win32.git
cd fogbow-powernap-win32
PYTHON_DIR/python.exe setup.py install

cd $BUILD_DIR

# clone qemu-win-driver
git clone https://github.com/fogbow/nova-qemu-win-driver.git

# clone nova
git clone https://github.com/openstack/nova.git
cd $NOVA_DIR
git checkout stable/havana

# stage qemu-win-driver
cp -r $BUILD_DIR/nova-qemu-win-driver/qemuwin nova/virt/

# install nova
PYTHON_DIR/python.exe setup.py install
