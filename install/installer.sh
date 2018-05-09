#!/bin/bash
echo "Copying files..."
sudo cp -rf maked/* /usr/bin
sudo cp -rf otagen/ /usr
sudo chmod 755 /usr/bin/akb_* 
sleep 2
echo "Done!"
