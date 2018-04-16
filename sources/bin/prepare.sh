#!/bin/bash
# by fuldaros
# EXPORT
function exportcm {
export ARCH="$arch"
export TARGET_ARCH="$arch"
export KBUILD_BUILD_USER="$author"
export KBUILD_BUILD_HOST="$bh"
};
clear
ver=1.0;
device=$(sed -n 12p make.prop);
e="\x1b[";c=$e"39;49;00m";y=$e"93;01m";cy=$e"96;01m";r=$e"1;91m";g=$e"92;01m";m=$e"95;01m";
conf=$(sed -n 6p make.prop);
arch=$(sed -n 4p make.prop);
echo -e "
$cy****************************************************
$cy*           Automatic kernel builder v"$ver"          *
$cy*                   by fuldaros                    *
$cy****************************************************
$y";
sleep 3     
set -e 
./bin/akb_clean
rm -f gen.info
mkdir out
mkdir outkernel
mkdir outzip
exportcm;
stamp=$(date +"%H:%M:%S %Y.%m.%d");
echo "generated by fuldaros's script on "$stamp" " > gen.info
cd sources
make O=../out/akb_"$device" "$conf"
cd ../
./bin/akb_build
####### script v1.2 (stable)
