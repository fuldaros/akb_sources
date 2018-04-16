#!/bin/bash
# by fuldaros
e="\x1b[";c=$e"39;49;00m";y=$e"93;01m";cy=$e"96;01m";r=$e"1;91m";g=$e"92;01m";m=$e"95;01m";
echo -e "$g  BUILDING GEN_AKB_INSTALL$y"
sleep 2;
cd btool
mkdir ../binary_btool
./akb_cc -v -f gen_akb_install.sh
rm -f gen_akb_install.sh.x.c
cd ../
cat btool/gen_akb_install.sh.x > binary_btool/gen_akb_install
rm -f btool/gen_akb_install.sh.x
chmod 777 binary_btool/gen_akb_install
./binary_btool/gen_akb_install
