# fuldaros @ 4pda
## OTA setup
# begin properties
properties() {
do.devicecheck=1
do.cleanup=1
do.cleanuponabort=1
} # end properties
# shell variables
loc=$(sed -n 18p /tmp/otapack/author.prop);
block="$loc"
is_slot_device=0;
## OTA methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/otapack/tools/fcore.sh;
## boot install
split_boot;
flash_boot;
## end install
