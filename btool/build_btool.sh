#!/bin/bash
# by fuldaros
cd btool
mkdir ../binary_btool
./shc -v -f gen_akb.sh
rm -f gen_akb.sh.x.c
cd ../
cat btool/gen_akb.sh.x > binary_btool/gen_akb
rm -f btool/gen_akb.sh.x
chmod 777 binary_btool/gen_akb
./binary_btool/gen_akb
