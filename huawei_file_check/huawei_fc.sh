#!/bin/bash

mkdir file_check
pilih_file_NL=$(zenity --file-selection --file-filter='ZIP files (zip) | *.zip' --title="Pilih File Parent NL nya" --filename=/home/iqbal/Kerja/imobi/task/Operation/log/) #nyari file yang mau di proses
cp "$pilih_file_NL" file_check/

## buka log di folder khusus
(cd file_check/ || return #return buat antisipasi kalau gagal masuk folder
unzip -- *.zip
gzip -d -- *.gz #buka bungkus log yang  berekstensi .gz
)

## baca file log di folder khusus, grep yang dibutuhkan, hasilnya dirangkum di folder utama
(cd file_check/ || return #return buat antisipasi kalau gagal masuk folder
list_log=$(ls -- *[.log])
for item in $list_log; do
    echo "Sedang memproses $item"  
    grep -oP "(?<=Network loaded from /opt/raw_data/huawei/sd/[2,3]g/oss_)[^ ]*" "$item" >> "file_check.txt" # cari daftar BSC/RNC Huawei
    
done
echo "Selesai"
cp "file_check.txt" ..)

## Pengelompokan sesuai MBSC/RNC dilanjut pengelompokan sesuai OSS
( mkdir "cfgmml" 
grep "MBSC" "file_check.txt" > "cfgmml/file_check_MBSC.txt"
grep "RNC" "file_check.txt" > "cfgmml/file_check_RNC.txt"
cd cfgmml/ || return

kelompok_oss()
{
	echo "sedang mengelompokan OSS $1"
	grep "$1" file_check_MBSC.txt >> "2G_$1.txt" 
	grep "$1" file_check_RNC.txt >> "3G_$1.txt"
}

kelompok_oss "Jabodetabek_23"
kelompok_oss "Nusa_Tenggara"
kelompok_oss "North_Sumatera"
kelompok_oss "East_Java"
kelompok_oss "South_Sumatera"
#kelompok_oss "Jabodetabek_26" #suspend, masih belum clear
kelompok_oss "Central_Java"
kelompok_oss "Jabodetabek_18"
kelompok_oss "Bali"
kelompok_oss "West_Java"
kelompok_oss "Central_Sumatera"
kelompok_oss "South_Sumatera"
kelompok_oss "North_Sumatera"
)

## Mencocokan antara database dan CFGMML, bila ada yang kurang, lempar ke file csv untuk dilaporkan
(
cd database/
ls > "list_database.txt"
for list in "list_database.txt" ; do
	for item in "$list" ; do
	echo "$item" | tr '\n' ',' >> "file_check.csv"
	grep "$item" "../cfgmml/$list" >> "file_check.csv" || if [ $? -eq 1 ] ; then echo "tidak ditemukan" >> "file_check.csv" ; else return; fi #search data BSC/RNC dari file database, dicocokan dengan yang ada di CFGMML
	done
done
echo "Mencocokan file selesai, saatnya save file ke folder yang diinginkan"
mv "file_check.csv" ..
)

##aktifitas selesai, saatnya simpen file penting dan bersih bersih
simpen_file=$(zenity --file-selection --directory --title="Pilih tempat simpan file" --filename="$pilih_file_NL")
zip -r file_check.zip cfgmml/ file_check.txt
mv file_check.csv file_check.zip "$simpen_file" #pindahin file csv ke folder pilihan pengguna
rm --recursive  file_check cfgmml file_check.txt #bersihin folder tempat ekstrak file, dll

