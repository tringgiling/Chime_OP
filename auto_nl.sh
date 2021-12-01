#!/bin/bash

mkdir NL
nama_zip=$(ls -- *[.zip]) #tangkep file yang berekstensi zip
cp "$nama_zip" NL/

## buka log di folder khusus
(cd NL/ || return #return buat antisipasi kalau gagal masuk folder
unzip "$nama_zip"
gzip -d -- *.gz #buka bungkus log yang  berekstensi .gz
)

## baca file log di folder khusus, grep yang dibutuhkan, hasilnya dirangkum di folder utama
(cd NL/ || return #return buat antisipasi kalau gagal masuk folder
list_log=$(ls -- *[.log])
for item in $list_log; do
    cat "hasil_NL.txt"
    echo "$item"
    grep -oP "(?<=Path /opt/raw_data/)[^ ]*" "$item" | tr '\n' ',' >> "hasil_NL.txt" #search nama OSS, tech nya + vendornya , dan trim newline menjadi "," supaya mudah dibuat csv file
    egrep -o "[0-9]{1,4} file-based networks were built" "$item" | egrep -o "[0-9]{1,4}" >> "hasil_NL.txt" || if [ $? -eq 1 ] ; then echo "fail" >> "hasil_NL.txt" ; else return; fi #search nilai MOLoad di OSS tersebut
done
cp "hasil_NL.txt" ..
)

## mensortir file nya sesuai teknologi, yang 2g, 3g dan 4g, diurutkan sesuai abjad OSS
(grep "2g" hasil_NL.txt | sort > NL.csv ; echo " " >> NL.csv
grep "3g" hasil_NL.txt  | sort >> NL.csv ; echo " " >> NL.csv
grep "4g" hasil_NL.txt  | sort >> NL.csv
)

##aktifitas selesai, saatnya bersih bersih
rm --recursive NL
