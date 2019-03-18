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

  # LINK VAR
  function linkvar() {
    usr=$a1
    bh=$a2
    arch=$a3
    stamp=$a4
    stampt=$a5
    logb=$a6
    otazip=$a7
    device=$a8
    cpu=$a9
    imgt=$a10
    loc=$a11
    gcc=$a12
    sha=$a13
    archp=$(dpkg --print-architecture)
    cpus=$(cat /proc/cpuinfo | grep processor | wc -l)
    th=$(($cpus + 1)) 
 }

  # EXPORT
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
    echo "ZIP file is generated automatically by fuldaros's script on "$stamp""\n"Good luck!" > generated.info
    echo -e "$g Генерируем author.prop...$y"
    sleep 2
    cat ../make.prop >author.prop
    echo -e "# BUILD TIME" "\n""$stampt" >> author.prop
    echo -e "# AKB ver. (DONT EDIT)""\n""$ver" >> author.prop
    echo -e "#BUILD TYPE" "\n""$type" >> author.prop
    echo -e "$g Сжимаем...$y"
    sleep 3
    zip -r ../out/ota/"$otazip".zip *
  }

  # Вывод информации о сборке
  function printinfo() {
    echo -e "$cy******************************$y"
    echo -e "$g   Build info"
    echo -e "$y    User: "$usr"
    Host: "$bh"
    ARCH: "$arch"
    CPU: "$cpu"
    Device: "$device"
    Build time: "$stamp"
    Kernel location: "$loc"
    Build type: "$type"
    Threads: "$th""
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
  echo -e "
    $cy****************************************************
    $cy*       Automatic kernel builder v"$ver"      *
    $cy*                   by xyzmean                     *
    $cy*           PaperPlane marmite Edition             *
    $cy****************************************************
    $y"
  sleep 3
  # Прерываем выполнение при появлении пошибки
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
  # Экспортируем необходимые значения из make.prop
  exportmkval
  printinfo
  sleep 4
  # Экспортируем gcc из make.prop
#  if [["$archp" = "amd64"]]; then
    export CROSS_COMPILE="$PWD"/gcc/bin/"$gcc"
#  else 
#    echo "Your arch not amd64!";
#  fi
  cd sources/
  echo -e "$g Начинаем сборку ядра...$y"
  strt=$(date +"%s")
  # Сборка ядра :3
  make -j$th O=../out/build/"$device" "$imgt"
  clear
  echo -e "
$cy****************************************************
$cy*           Automatic kernel builder v"$ver"          *
$cy*                   by xyzmean                    *
$cy****************************************************
    $y"
  echo -e "$g Сборка завершена!
    Переносим ядро в out/kernel... $y"
  sleep 3
  # Перенос ядра в папку out/kernel
  cat ../out/build/"$device"/arch/"$arch"/boot/"$imgt" >../out/kernel/"$kernel"
  rm -rf ../out/build/"$device"/arch/"$arch"/boot/
  cd ../
  mkota
  echo -e "$g Удаление временных фаилов...$y"
  # Отчистка tmp фаилов
  sleep 1
  cleantmp
  echo -e "$g Готово! Имя OTA пакета: "$otazip".zip$y"
  # Вывод времени сборки
  end=$(date +"%s")
  diff=$(($end - $strt))
  echo Операция выполнена успешно!
  sleep 2
  echo -e "$m Компиляция заняла "$diff" секунд!"
fi
####### script v12 (beta)
