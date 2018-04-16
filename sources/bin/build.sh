#!/bin/bash
# by fuldaros
# Хрень какай-то
## FUNCTIONS START
# CLEAN TMP
function cleantmp {
rm -rf out/akb_"$device"/include/generated/compile.h
rm -f zImage
rm -f generated.info
rm -f author.prop
};
# CREATE VAR
function createvar {
usr=$(sed -n 2p make.prop);
bh=$(sed -n 8p make.prop);
arch=$(sed -n 4p make.prop);
stamp=$(date +"%Y.%m.%d %H:%M");
stampt=$(date +"%d.%m.%Y-%H:%M");
logb=logb_"$stamp";
otazip=ota_akb_"$stamp";
device=$(sed -n 12p make.prop);
cpu=$(sed -n 10p make.prop);
imgt=$(sed -n 14p make.prop);
loc=$(sed -n 18p make.prop);
gcc=$(sed -n 16p make.prop);
sha="0"
};
# EXPORT
function exportcm {
export ARCH="$arch"
export TARGET_ARCH="$arch"
export KBUILD_BUILD_USER="$author"
export KBUILD_BUILD_HOST="$bh"
};
# MAKE OTA PACK
function mkota {
echo -e "$g Собираем OTA пакет...$y"
cat outkernel/"$kernel" > otagen/zImage
cd otagen
echo "ZIP file is generated automatically by fuldaros's script on "$stamp"
Good luck!" > generated.info
echo -e "$g Генерируем author.prop...$y"
sleep 2
cat ../make.prop > author.prop
echo -e "# BUILD TIME" "\n""$stampt" >> author.prop
echo -e "# AKB ver. (DONT EDIT)""\n""$ver" >> author.prop
echo -e "#BUILD TYPE" "\n""$type" >> author.prop
echo -e "$g Сжимаем...$y"
sleep 3
zip -r ../outzip/"$otazip".zip *
};
## FUNCTIONS END
ver=0.7;
clear
e="\x1b[";c=$e"39;49;00m";y=$e"93;01m";cy=$e"96;01m";r=$e"1;91m";g=$e"92;01m";m=$e"95;01m";
echo -e "
$cy****************************************************
$cy*           Automatic kernel builder v"$ver"          *
$cy*                   by fuldaros                    *
$cy****************************************************
$y";
sleep 3
# Прерываем выполнение при появлении пошибки 
set -e
# Создание переменных
createvar;
# Тип сборки (бесполезная хрень)
if [[ "$sha" != "1" ]]
then
type="USER";
else
type="OFFICIAL";
fi
# Еще переменная
kernel="$imgt"_akb_"$stamp";
# Экспортируем необходимые значения из make.prop
exportcm;
# Вывод информации о сборки
echo -e "$cy******************************$y"
echo -e "$g   Build info";
echo -e "$y User: "$usr"
 Host: "$bh"
 ARCH: "$arch"
 CPU: "$cpu"
 Device: "$device"
 Build time: "$stamp"
 Kernel location: "$loc"
 Build type: "$type"";
echo -e "$cy******************************$y"
sleep 4
# Экспортируем gcc из make.prop
export CROSS_COMPILE="$PWD"/gcc/bin/"$gcc"
cd sources/
echo -e "$g Начинаем сборку ядра...$y"
strt=$(date +"%s")
# Сборка ядра :3
make -j3 O=../out/akb_"$device" "$imgt" > ../outkernel/"$logb"
clear
echo -e "
$cy****************************************************
$cy*           Automatic kernel builder v"$ver"          *
$cy*                   by fuldaros                    *
$cy****************************************************
$y";  
echo -e "$g Сборка завершена!
 Переносим ядро в outkernel... $y"
sleep 3
# Перенос ядра в папку outkernel
cat ../out/akb_"$device"/arch/"$arch"/boot/"$imgt" > ../outkernel/"$kernel"
rm -rf ../out/akb_"$device"/arch/"$arch"/boot/
cd ../
mkota;
echo -e "$g Удаление временных фаилов...$y"
# Отчистка tmp фаилов
sleep 1
cleantmp;
echo -e "$g Готово! Имя OTA пакета: "$otazip".zip$y"
# Вывод времени сборки
end=$(date +"%s")
diff=$(( $end - $strt ))
echo Операция выполнена успешно!
sleep 2
echo -e "$m Компиляция заняла "$diff" секунд!"
####### script v09 (beta)
