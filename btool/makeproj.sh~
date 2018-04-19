#!/bin/bash
# by fuldaros
rm -rf build/
mkdir build/
mkdir build/bin
mkdir build/sources
cp -rf sources/otagen/ build/
cp -rf tmplib/* build/otagen/
mkdir  build/gcc
cp -rf LICENSE build/
cp -rf sources/make.prop build/
cp -rf README.md build/
cp sources/makefile build/
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
		cat $file.sh.x > ../../build/bin/akb_"$file"
		rm -rf $file.sh.x
# build prepare
file=prepare
	makej;
		rm -f $file.sh.x.c
		cat $file.sh.x > ../../build/bin/akb_"$file"
		rm -rf $file.sh.x
# build clean
file=clean
	makej;
		rm -f $file.sh.x.c
		cat $file.sh.x > ../../build/bin/akb_"$file"
		rm -rf $file.sh.x
cd ../
