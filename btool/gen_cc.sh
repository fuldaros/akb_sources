#!/bin/bash
cd cc/
make
cd ..
cp -rf cc/akb_cc btool
rm -rf cc/akb_cc
