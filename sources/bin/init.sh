#!/bin/bash
echo " Please wait...";
mkdir ../tmp
mv * ../tmp
mkdir sources
mkdir gcc
mv ../tmp/* sources/
rm -rf ../tmp
echo "// YOUR NAME (a.k.a build user)
name_here
// ARCH (arm/arm64)
arch_here
// DEFCONFIG NAME 
defconfig_here
// BUILD HOST
build_host_here
// CPU
cpu_here
// Device
device_here
// Image type (zImage/Image/Image.gz-dtb/...)
image_type_here
// GCC perfix
gcc__perfix_here
// Kernel location
kernel_location_here" > make.prop
echo " Done!";
