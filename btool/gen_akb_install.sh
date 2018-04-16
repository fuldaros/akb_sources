#!/bin/bash
# by fuldaros
e="\x1b[";c=$e"39;49;00m";y=$e"93;01m";cy=$e"96;01m";r=$e"1;91m";g=$e"92;01m";m=$e"95;01m";
echo -e "$g  BUILDING BTOOL'S$y"
sleep 2;
ver=1.0
cd btool
./akb_cc -v -f makeinstall.sh
rm -f makeinstall.sh.x.c
cd ../
cat btool/makeinstall.sh.x > binary_btool/makeinstall
rm -f btool/makeinstall.sh.x
chmod 777 binary_btool/makeinstall
./binary_btool/makeinstall
chmod -R 777 build/
rm -rf binary_btool/
cd build/
mkdir ../tmp
mkdir ../tmp/akb_"$ver"
cp -rf * ../tmp/akb_"$ver"
cd ../tmp/
rm -rf ../out
mkdir ../out
e="\x1b[";c=$e"39;49;00m";y=$e"93;01m";cy=$e"96;01m";r=$e"1;91m";g=$e"92;01m";m=$e"95;01m";
echo -e "$g  BUILDING ZIP PACKAGE$y"
sleep 2;
zip -r ../out/akb_installer_"$ver"-release.zip *
cd ../
rm -rf tmp/
e="\x1b[";c=$e"39;49;00m";y=$e"93;01m";cy=$e"96;01m";r=$e"1;91m";g=$e"92;01m";m=$e"95;01m";
echo -e "$g  DONE!$y"
sleep 2;
