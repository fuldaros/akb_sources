#!/bin/bash
# by xyzmean

## FUNCTIONS START
# CLEAN TMP
export a1=$(sed -n 2p make.prop)
export a2=$(sed -n 8p make.prop)
export a3=$(sed -n 4p make.prop)
export a4=$(date +"%Y.%m.%d %H:%M")
export a5=$(date)
export a6=logb_"$a4"
export a8=$(sed -n 12p make.prop)
export a7=ota_"$a8"_"$a4"
export a9=$(sed -n 10p make.prop)
export a10=$(sed -n 14p make.prop)
export a11=$(sed -n 18p make.prop)
export a12=$(sed -n 16p make.prop)
export a13="1"

# Проверка make.prop на кол-во строк
ch1=$(sed -n 19p make.prop)
if [ "$ch1" != "" ]; then
  echo "FATAL! Bad make.prop"
  exit
else
  function cleantmp() {
    rm -rf out/build/"$device"/include/generated/compile.h
    rm -f zImage
    rm -f generated.info
    rm -f author.prop
  }

  # Необходимо явно объявлять переменные с помощью local
  function linkvar() {
    local usr=$a1
    local bh=$a2
    local arch=$a3
    local stamp=$a4
    local stampt=$a5
    local logb=$a6
    local otazip=$a7
    local device=$a8
    local cpu=$a9
    local imgt=$a10
    local loc=$a11
    local gcc=$a12
    local sha=$a13
    local archp=$(dpkg --print-architecture)
    local cpus=$(cat /proc/cpuinfo | grep processor | wc -l)
    local th=$(($cpus + 1))
  }

  # Экспорт необходимых данных для сборки
  function exportmkval() {
    export ARCH="$arch"
    export TARGET_ARCH="$arch"
    export KBUILD_BUILD_USER="$author"
    export KBUILD_BUILD_HOST="$bh"
  }

  # MAKE OTA PACK
  function mkota() {
    echo -e "$g Собираем OTA пакет...$y"
    cat out/kernel/"$kernel" > otagen/zImage
    cd otagen
    echo "ZIP file is generated automatically by fuldaros's script on "$stamp""$'\n'"Good luck!" > generated.info
    echo -e "$g Генерируем author.prop...$y"
    sleep 2
    cat ../make.prop > author.prop
    echo -e "# BUILD TIME"$'\n'"$stampt" >> author.prop
    echo -e "# AKB ver. (DONT EDIT)"$'\n'"$ver" >> author.prop
    echo -e "# BUILD TYPE"$'\n'"$type" >> author.prop
    echo -e "$g Сжимаем...$y"
    sleep 3
    zip -r ../out/ota/"$otazip".zip *
  }

  # Вывод информации о сборке
  function printinfo() {
    echo -e "$cy******************************$y"
    echo -e "$g   Build info"
    echo -e "$y    User: $usr"
    echo -e "    Host: $bh"
    echo -e "    ARCH: $arch"
    echo -e "    CPU: $cpu"
    echo -e "    Device: $device"
    echo -e "    Build time: $stamp"
    echo -e "    Kernel location: $loc"
    echo -e "    Build type: $type"
    echo -e "    Threads: $th"
    echo -e "$cy******************************$y"
  }

  ## FUNCTIONS END

  ver=1.5-nightly
  clear
  e="\x1b["
  c=$e"39;49;00m"
  y=$e"93;01m"
  cy=$e"96;01m"
  r=$e"1;91m"
  g=$e"92;01m"
  m=$e"95;01m"
  echo -e "$cy****************************************************
$cy*           Automatic kernel builder v"$ver"          *
$cy*                   by xyzmean                    *
$cy****************************************************
$y"
  sleep 3
 
  # Прерывание выполнения при возникновении ошибки
  set -e
 
  # Создание переменных
  linkvar
 
  # Тип сборки (бесполезная хрень)
  if [[ "$sha" != "1" ]]; then
    type="USER"
  else
    type="OFFICIAL"
  fi
 
  # Еще переменная
  kernel="$imgt"_"$stamp"
 
  # Экспорт необходимых данных для сборки
  exportmkval
 
  printinfo
 
  sleep 4
 
  # Экспорт gcc из make.prop
  if [[ "$archp" = "amd64" ]]; then
    export CROSS_COMPILE="$PWD"/gcc/bin/"$gcc"
  else 
    echo "Your arch not amd64!"
  fi
 
  cd sources/
 
  echo -e "$g Building the kernel...$y"
 
  strt=$(date +"%s")
 
  # Сборка ядра
  make -j$th O=../out/build/"$device" "$imgt"
 
  clear
 
  # Заголовок завершения сборки
  echo -e "
$cy****************************************************
$cy*           Automatic kernel builder v"$ver"          *
$cy*                   by xyzmean                    *
$cy****************************************************
$y"
 
  echo -e "$g Build completed!
    Transferring the kernel to out/kernel... $y"
 
  sleep 3
 
  # Перенос ядра в папку out/kernel
  cat ../out/build/"$device"/arch/"$arch"/boot/"$imgt" >../out/kernel/"$kernel"
  rm -rf ../out/build/"$device"/arch/"$arch"/boot/
  cd ../
  mkota
 
  echo -e "$g Removing temporary files...$y"
 
  # Очистка временных файлов
 
  sleep 1
  cleantmp
 
  # Вывод имени созданного пакета
  echo -e "$g Done! OTA package name: "$otazip".zip$y"
 
  # Генерация и вывод времени сборки
  end=$(date +"%s")
  diff=$(($end - $strt))
  echo Operation completed successfully!
  sleep 2
  echo -e "$m Compilation took $diff seconds!"
fi

####### script v12 (beta)
