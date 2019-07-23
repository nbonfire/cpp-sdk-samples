#!/bin/sh 
# Script for fetching and configuring libva.so.1 dependency for frame-detector-demos. 

wget http://ftp5.gwdg.de/pub/linux/archlinux/community/os/x86_64//libva1-1.8.3-2-x86_64.pkg.tar.xz

tar --warning=none -xf libva1-1.8.3-2-x86_64.pkg.tar.xz

echo "Copying libva.so.1 dependency into "$AFFECTIVA_SDK_DIR"lib directory..."
cp usr/lib/libva1/libva.so.1 $AFFECTIVA_SDK_DIR/lib

echo "Removing tar file and its directories..."
rm -rf usr/ etc/
rm libva1-1.8.3-2-x86_64.pkg.tar.xz
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$AFFECTIVA_SDK_DIR/lib

echo "-------------------------------FINISHED---------------------------------"
