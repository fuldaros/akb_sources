#!/bin/bash
# by fuldaros
mkdir build/
mkdir build/bin
mkdir build/sources
cp -rf sources/otagen/ build/
mkdir  build/gcc
cp -rf LICENSE build/
cp -rf sources/make.prop build/
cp -rf README.md build/
cp sources/makefile build/
cd sources/bin
makej() {
../../btool/shc -v -f $file.sh
};
# build binary
file=build
makej;
rm -f $file.sh.x.c
cat $file.sh.x > ../../build/bin/"$file"
rm -rf $file.sh.x
# build prepare
file=prepare
makej;
rm -f $file.sh.x.c
cat $file.sh.x > ../../build/bin/"$file"
rm -rf $file.sh.x
# build clean
file=clean
makej;
rm -f $file.sh.x.c
cat $file.sh.x > ../../build/bin/"$file"
rm -rf $file.sh.x
cd ../
