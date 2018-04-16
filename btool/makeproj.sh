#!/bin/bash
# by fuldaros
mkdir build/
mkdir build/bin
cp -rf sources/ build/
cp -rf otagen/ build/
cp -rf tools/ build/
cp -rf LICENSE build/
cp -rf make.prop build/
cp -rf README.md build/
makej() {
./shc -v -f $file.sh
};
# build binary
file=build
makej;
rm -f $file.sh.x.c
cat $file.sh.x > build/"$file"
rm -rf $file.sh.x
# build prepare
file=prepare
makej;
rm -f $file.sh.x.c
cat $file.sh.x > build/"$file"
rm -rf $file.sh.x
# build clean
cd bin
../shc -v -f clean.sh
rm -f clean.sh.x.c
cat clean.sh.x > clean
rm -f clean.sh.x
rm -f sch
cd ../
mv bin/clean build/bin
