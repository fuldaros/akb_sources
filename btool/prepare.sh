#!/bin/bash
echo "MAKING bootimg_tools"
sleep 3;
mkdir tmplib/
cd bootimg_tools
make all
cp -rf mkbootimg/mkbootimg ../tmplib
cat mkbootimg/unmkbootimg > mkbootimg/unpackbootimg
mv mkbootimg/unpackbootimg ../tmplib
make clean
echo "Done!"
sleep 3;
cd ../
