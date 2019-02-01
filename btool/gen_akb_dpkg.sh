#!/bin/bash
# by fuldaros
e="\x1b[";c=$e"39;49;00m";y=$e"93;01m";cy=$e"96;01m";r=$e"1;91m";g=$e"92;01m";m=$e"95;01m";
echo -e "$g  BUILDING BTOOL'S$y"
sleep 2;
ver=1.5-nightly
cd btool
./akb_cc -v -f makedpkg.sh
rm -f makedpkg.sh.x.c
cd ../
cat btool/makedpkg.sh.x > binary_btool/makedpkg
rm -f btool/makedpkg.sh.x
chmod 777 binary_btool/makedpkg
./binary_btool/makedpkg
chmod -R 777 build/
rm -rf binary_btool/
mkdir out
cd out
dpkg -b ../dpkg_tmp
mv ../dpkg_tmp.deb akb_"$ver".deb
cd ../
rm -rf dpkg_tmp/
