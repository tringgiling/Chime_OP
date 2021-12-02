#!/bin/bash

mkdir NL
pilih_file_NL=$(zenity --file-selection --file-filter='ZIP files (zip) | *.zip' --title="Pilih File Parent NL nya" --filename=/home/iqbal/Kerja/imobi/task/Operation/log/) #nyari file yang mau di proses
cp "$pilih_file_NL" NL/

## buka log di folder khusus
(cd NL/ || return #return buat antisipasi kalau gagal masuk folder
unzip -- *.zip
gzip -d -- *.gz #buka bungkus log yang  berekstensi .gz
)

## baca file log di folder khusus, grep yang dibutuhkan, hasilnya dirangkum di folder utama
(cd NL/ || return #return buat antisipasi kalau gagal masuk folder
list_log=$(ls -- *[.log])
for item in $list_log; do
    echo "Sedang memproses $item"
    grep -oP "(?<=Path /opt/raw_data/)[^ ]*" "$item" | tr '\n' ',' >> "hasil_NL.txt" #search nama OSS, tech nya + vendornya , dan trim newline menjadi "," supaya mudah dibuat csv file
    egrep -o "[0-9]{1,4} file-based networks were built" "$item" | egrep -o "[0-9]{1,4}" >> "hasil_NL.txt" || if [ $? -eq 1 ] ; then echo "fail" >> "hasil_NL.txt" ; else return; fi #search nilai NLoad di OSS tersebut, ambil angkanya aja
done
echo "Selesai"
cp "hasil_NL.txt" ..)

#Urutkan sesuai teknologi dan OSS, lalu simpan hasilnya dalam bentuk csv
(grep "2g" hasil_NL.txt | sort ; echo " "
grep "3g" hasil_NL.txt  | sort ; echo " "
grep "4g" hasil_NL.txt  | sort ) >NL.csv

##aktifitas selesai, saatnya simpen file penting dan bersih bersih
simpen_file=$(zenity --file-selection --directory --title="Pilih tempat simpan file" --filename="$pilih_file_NL")
mv NL.csv hasil_NL.txt "$simpen_file" #pindahin file csv ke folder pilihan pengguna
rm --recursive NL #bersihin folder tempat ekstrak file NL
