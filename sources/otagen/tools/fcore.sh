# set up extracted files and directories
bin=/tmp/otapack/tools;
split_img=/tmp/otapack/split_img;
patch=/tmp/otapack/patch;

chmod -R 755 $bin;
mkdir -p $split_img;

FD=$1;
OUTFD=/proc/self/fd/$FD;

# ui_print <text>
ui_print() { echo -e "ui_print $1\nui_print" > $OUTFD; }

# dump boot and extract ramdisk
split_boot() {
  if [ ! -e "$(echo $block | cut -d\  -f1)" ]; then
    ui_print " "; ui_print "Invalid partition. Aborting..."; exit 1;
  fi;
  if [ -f "$bin/nanddump" ]; then
    $bin/nanddump -f /tmp/otapack/boot.img $block;
  else
    dd if=$block of=/tmp/otapack/boot.img;
  fi;
  nooktest=$(strings /tmp/otapack/boot.img | grep -E 'Red Loader|Green Loader|Green Recovery|eMMC boot.img|eMMC recovery.img|BauwksBoot');
  if [ "$nooktest" ]; then
    case $nooktest in
      *BauwksBoot*) nookoff=262144;;
      *) nookoff=1048576;;
    esac;
    mv -f /tmp/otapack/boot.img /tmp/otapack/boot-orig.img;
    dd bs=$nookoff count=1 conv=notrunc if=/tmp/otapack/boot-orig.img of=$split_img/boot.img-master_boot.key;
    dd bs=$nookoff skip=1 conv=notrunc if=/tmp/otapack/boot-orig.img of=/tmp/otapack/boot.img;
  fi;
  if [ -f "$bin/unpackelf" -a "$($bin/unpackelf -i /tmp/otapack/boot.img -h -q 2>/dev/null; echo $?)" == 0 ]; then
    if [ -f "$bin/elftool" ]; then
      mkdir $split_img/elftool_out;
      $bin/elftool unpack -i /tmp/otapack/boot.img -o $split_img/elftool_out;
      cp -f $split_img/elftool_out/header $split_img/boot.img-header;
    fi;
    $bin/unpackelf -i /tmp/otapack/boot.img -o $split_img;
    mv -f $split_img/boot.img-ramdisk.cpio.gz $split_img/boot.img-ramdisk.gz;
  elif [ -f "$bin/dumpimage" ]; then
    $bin/dumpimage -l /tmp/otapack/boot.img;
    $bin/dumpimage -l /tmp/otapack/boot.img > $split_img/boot.img-header;
    grep "Name:" $split_img/boot.img-header | cut -c15- > $split_img/boot.img-name;
    grep "Type:" $split_img/boot.img-header | cut -c15- | cut -d\  -f1 > $split_img/boot.img-arch;
    grep "Type:" $split_img/boot.img-header | cut -c15- | cut -d\  -f2 > $split_img/boot.img-os;
    grep "Type:" $split_img/boot.img-header | cut -c15- | cut -d\  -f3 | cut -d- -f1 > $split_img/boot.img-type;
    grep "Type:" $split_img/boot.img-header | cut -d\( -f2 | cut -d\) -f1 | cut -d\  -f1 | cut -d- -f1 > $split_img/boot.img-comp;
    grep "Address:" $split_img/boot.img-header | cut -c15- > $split_img/boot.img-addr;
    grep "Point:" $split_img/boot.img-header | cut -c15- > $split_img/boot.img-ep;
    $bin/dumpimage -i /tmp/otapack/boot.img -p 0 $split_img/boot.img-zImage;
    test $? != 0 && dumpfail=1;
    if [ "$(cat $split_img/boot.img-type)" == "Multi" ]; then
      $bin/dumpimage -i /tmp/otapack/boot.img -p 1 $split_img/boot.img-ramdisk.gz;
    fi;
    test $? != 0 && dumpfail=1;
  elif [ -f "$bin/rkcrc" ]; then
    dd bs=4096 skip=8 iflag=skip_bytes conv=notrunc if=/tmp/otapack/boot.img of=$split_img/boot.img-ramdisk.gz;
  elif [ -f "$bin/pxa-unpackbootimg" ]; then
    $bin/pxa-unpackbootimg -i /tmp/otapack/boot.img -o $split_img;
  else
    $bin/unpackbootimg -i /tmp/otapack/boot.img -o $split_img;
  fi;
  if [ $? != 0 -o "$dumpfail" ]; then
    ui_print " "; ui_print "Dumping/splitting image failed. Aborting..."; exit 1;
  fi;
  if [ -f "$bin/unpackelf" -a -f "$split_img/boot.img-dtb" ]; then
    case $(od -ta -An -N4 $split_img/boot.img-dtb | sed -e 's/del //' -e 's/   //g') in
      QCDT|ELF) ;;
      *) gzip $split_img/boot.img-zImage;
         mv -f $split_img/boot.img-zImage.gz $split_img/boot.img-zImage;
         cat $split_img/boot.img-dtb >> $split_img/boot.img-zImage;
         rm -f $split_img/boot.img-dtb;;
    esac;
  fi;
}
flash_boot() {
  cd $split_img;
  if [ -f "$bin/mkimage" ]; then
    name=`cat *-name`;
    arch=`cat *-arch`;
    os=`cat *-os`;
    type=`cat *-type`;
    comp=`cat *-comp`;
    test "$comp" == "uncompressed" && comp=none;
    addr=`cat *-addr`;
    ep=`cat *-ep`;
  else
    if [ -f *-cmdline ]; then
      cmdline=`cat *-cmdline`;
      cmd="$split_img/boot.img-cmdline@cmdline";
    fi;
    if [ -f *-board ]; then
      board=`cat *-board`;
    fi;
    base=`cat *-base`;
    pagesize=`cat *-pagesize`;
    kerneloff=`cat *-kerneloff`;
    ramdiskoff=`cat *-ramdiskoff`;
    if [ -f *-tagsoff ]; then
      tagsoff=`cat *-tagsoff`;
    fi;
    if [ -f *-osversion ]; then
      osver=`cat *-osversion`;
    fi;
    if [ -f *-oslevel ]; then
      oslvl=`cat *-oslevel`;
    fi;
    if [ -f *-second ]; then
      second=`ls *-second`;
      second="--second $split_img/$second";
      secondoff=`cat *-secondoff`;
      secondoff="--second_offset $secondoff";
    fi;
    if [ -f *-hash ]; then
      hash=`cat *-hash`;
      test "$hash" == "unknown" && hash=sha1;
      hash="--hash $hash";
    fi;
    if [ -f *-unknown ]; then
      unknown=`cat *-unknown`;
    fi;
  fi;
  for i in zImage zImage-dtb Image.gz Image Image-dtb Image.gz-dtb Image.bz2 Image.bz2-dtb Image.lzo Image.lzo-dtb Image.lzma Image.lzma-dtb Image.xz Image.xz-dtb Image.lz4 Image.lz4-dtb Image.fit; do
    if [ -f /tmp/otapack/$i ]; then
      kernel=/tmp/otapack/$i;
      break;
    fi;
  done;
  if [ ! "$kernel" ]; then
    kernel=`ls *-zImage`;
    kernel=$split_img/$kernel;
  fi;
  if [ -f /tmp/otapack/ramdisk-new.cpio.$compext ]; then
    rd=/tmp/otapack/ramdisk-new.cpio.$compext;
  else
    rd=`ls *-ramdisk.*`;
    rd="$split_img/$rd";
  fi;
  for i in dtb dt.img; do
    if [ -f /tmp/otapack/$i ]; then
      dtb="--dt /tmp/otapack/$i";
      rpm="/tmp/otapack/$i,rpm";
      break;
    fi;
  done;
  if [ ! "$dtb" -a -f *-dtb ]; then
    dtb=`ls *-dtb`;
    rpm="$split_img/$dtb,rpm";
    dtb="--dt $split_img/$dtb";
  fi;
  cd /tmp/otapack;
  if [ -f "$bin/mkmtkhdr" ]; then
    case $kernel in
      $split_img/*) ;;
      *) $bin/mkmtkhdr --kernel $kernel; kernel=$kernel-mtk;;
    esac;
  fi;
  if [ -f "$bin/mkimage" ]; then
    test "$type" == "Multi" && uramdisk=":$rd";
    $bin/mkimage -A $arch -O $os -T $type -C $comp -a $addr -e $ep -n "$name" -d $kernel$uramdisk boot-new.img;
  elif [ -f "$bin/elftool" ]; then
    $bin/elftool pack -o boot-new.img header=$split_img/boot.img-header $kernel $rd,ramdisk $rpm $cmd;
  elif [ -f "$bin/rkcrc" ]; then
    $bin/rkcrc -k $rd boot-new.img;
  elif [ -f "$bin/pxa-mkbootimg" ]; then
    $bin/pxa-mkbootimg --kernel $kernel --ramdisk $rd $second --cmdline "$cmdline" --board "$board" --base $base --pagesize $pagesize --kernel_offset $kerneloff --ramdisk_offset $ramdiskoff $secondoff --tags_offset "$tagsoff" --unknown $unknown $dtb --output boot-new.img;
  else
    $bin/mkbootimg --kernel $kernel --ramdisk $rd $second --cmdline "$cmdline" --board "$board" --base $base --pagesize $pagesize --kernel_offset $kerneloff --ramdisk_offset $ramdiskoff $secondoff --tags_offset "$tagsoff" --os_version "$osver" --os_patch_level "$oslvl" $hash $dtb --output boot-new.img;
  fi;
  if [ $? != 0 ]; then
    ui_print " "; ui_print "Repacking image failed. Aborting..."; exit 1;
  fi;
  if [ -f "$bin/futility" -a -d "$bin/chromeos" ]; then
    $bin/futility vbutil_kernel --pack boot-new-signed.img --keyblock $bin/chromeos/kernel.keyblock --signprivate $bin/chromeos/kernel_data_key.vbprivk --version 1 --vmlinuz boot-new.img --bootloader $bin/chromeos/empty --config $bin/chromeos/empty --arch arm --flags 0x1;
    if [ $? != 0 ]; then
      ui_print " "; ui_print "Signing image failed. Aborting..."; exit 1;
    fi;
    mv -f boot-new-signed.img boot-new.img;
  fi;
  if [ -f "$bin/BootSignature_Android.jar" -a -d "$bin/avb" ]; then
    if [ -f "/system/system/bin/dalvikvm" ]; then
      umount /system;
      umount /system 2>/dev/null;
      mkdir /system_root;
      mount -o ro -t auto /dev/block/bootdevice/by-name/system$slot /system_root;
      mount -o bind /system_root/system /system;
    fi;
    pk8=`ls $bin/avb/*.pk8`;
    cert=`ls $bin/avb/*.x509.*`;
    case $block in
      *recovery*|*SOS*) avbtype=recovery;;
      *) avbtype=boot;;
    esac;
    savedpath="$LD_LIBRARY_PATH";
    unset LD_LIBRARY_PATH;
    if [ "$(/system/bin/dalvikvm -Xbootclasspath:/system/framework/core-oj.jar:/system/framework/core-libart.jar:/system/framework/conscrypt.jar:/system/framework/bouncycastle.jar -Xnodex2oat -Xnoimage-dex2oat -cp $bin/BootSignature_Android.jar com.android.verity.BootSignature -verify boot.img | grep VALID)" ]; then
      /system/bin/dalvikvm -Xbootclasspath:/system/framework/core-oj.jar:/system/framework/core-libart.jar:/system/framework/conscrypt.jar:/system/framework/bouncycastle.jar -Xnodex2oat -Xnoimage-dex2oat -cp $bin/BootSignature_Android.jar com.android.verity.BootSignature /$avbtype boot-new.img $pk8 $cert boot-new-signed.img;
      if [ $? != 0 ]; then
        ui_print " "; ui_print "Signing image failed. Aborting..."; exit 1;
      fi;
    fi;
    test "$savedpath" && export LD_LIBRARY_PATH="$savedpath";
    mv -f boot-new-signed.img boot-new.img;
    if [ -d "/system_root" ]; then
      umount /system;
      umount /system_root;
      rmdir /system_root;
      mount -o ro -t auto /system;
    fi;
  fi;
  if [ -f "$bin/blobpack" ]; then
    printf '-SIGNED-BY-SIGNBLOB-\00\00\00\00\00\00\00\00' > boot-new-signed.img;
    $bin/blobpack tempblob LNX boot-new.img;
    cat tempblob >> boot-new-signed.img;
    mv -f boot-new-signed.img boot-new.img;
  fi;
  if [ -f "/data/custom_boot_image_patch.sh" ]; then
    ash /data/custom_boot_image_patch.sh /tmp/otapack/boot-new.img;
    if [ $? != 0 ]; then
      ui_print " "; ui_print "User script execution failed. Aborting..."; exit 1;
    fi;
  fi;
  if [ "$(strings /tmp/otapack/boot.img | grep SEANDROIDENFORCE )" ]; then
    printf 'SEANDROIDENFORCE' >> boot-new.img;
  fi;
  if [ -f "$bin/dhtbsign" ]; then
    $bin/dhtbsign -i boot-new.img -o boot-new-signed.img;
    mv -f boot-new-signed.img boot-new.img;
  fi;
  if [ -f "$split_img/boot.img-master_boot.key" ]; then
    cat $split_img/boot.img-master_boot.key boot-new.img > boot-new-signed.img;
    mv -f boot-new-signed.img boot-new.img;
  fi;
  if [ ! -f /tmp/otapack/boot-new.img ]; then
    ui_print " "; ui_print "Repacked image could not be found. Aborting..."; exit 1;
  elif [ "$(wc -c < boot-new.img)" -gt "$(wc -c < boot.img)" ]; then
    ui_print " "; ui_print "New image larger than boot partition. Aborting..."; exit 1;
  fi;
  if [ -f "$bin/flash_erase" -a -f "$bin/nandwrite" ]; then
    $bin/flash_erase $block 0 0;
    $bin/nandwrite -p $block /tmp/otapack/boot-new.img;
  else
    dd if=/dev/zero of=$block 2>/dev/null;
    dd if=/tmp/otapack/boot-new.img of=$block;
  fi;
  for i in dtbo dtbo.img; do
    if [ -f /tmp/otapack/$i ]; then
      dtbo=$i;
      break;
    fi;
  done;
  if [ "$dtbo" ]; then
    dtbo_block=/dev/block/bootdevice/by-name/dtbo$slot;
    if [ ! -e "$(echo $dtbo_block)" ]; then
      ui_print " "; ui_print "dtbo partition could not be found. Aborting..."; exit 1;
    fi;
    if [ -f "$bin/flash_erase" -a -f "$bin/nandwrite" ]; then
      $bin/flash_erase $dtbo_block 0 0;
      $bin/nandwrite -p $dtbo_block /tmp/otapack/$dtbo;
    else
      dd if=/dev/zero of=$dtbo_block 2>/dev/null;
      dd if=/tmp/otapack/$dtbo of=$dtbo_block;
    fi;
  fi;
}
## end methods

