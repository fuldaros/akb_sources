#!/bin/bash
# by fuldaros
rm -rf build/
mkdir build/
mkdir build/maked
cp tmplib build
cp -rf sources/otagen/ build/
cp -rf tmplib/* build/otagen/
rm -rf tmplib
cd sources/bin
makej() {
../../btool/akb_cc -v -f $file.sh
};
e="\x1b[";c=$e"39;49;00m";y=$e"93;01m";cy=$e"96;01m";r=$e"1;91m";g=$e"92;01m";m=$e"95;01m";
echo -e "$g  BUILDING BINARY$y"
sleep 3;
# build binary
file=build
makej;
rm -f $file.sh.x.c
cat $file.sh.x > ../../build/maked/akb_"$file"
rm -rf $file.sh.x
# build prepare
file=prepare_install
makej;
rm -f $file.sh.x.c
cat $file.sh.x > ../../build/maked/akb_prepare
rm -rf $file.sh.x
# build clean
file=clean
makej;
rm -f $file.sh.x.c
cat $file.sh.x > ../../build/maked/akb_"$file"
rm -rf $file.sh.x
# build init
file=init
makej;
rm -f $file.sh.x.c
cat $file.sh.x > ../../build/maked/akb_"$file"
rm -rf $file.sh.x
# build install
cd ../../install
file=installer
../btool/akb_cc -v -f $file.sh
rm -f $file.sh.x.c
cat $file.sh.x > ../build/"$file"
rm -rf $file.sh.x
