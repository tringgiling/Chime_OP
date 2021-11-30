#!/bin/bash

mkdir MOL
nama_zip=$(ls -- *[.zip]) #tangkep file yang berekstensi zip
cp "$nama_zip" MOL/

## buka log di folder khusus
(cd MOL/ || return #return buat antisipasi kalau gagal masuk folder
unzip "$nama_zip"
gzip -d -- *.gz #buka bungkus log yang  berekstensi .gz
)

## baca file log di folder khusus, grep yang dibutuhkan, hasilnya dirangkum di folder utama
(cd MOL/ || return #return buat antisipasi kalau gagal masuk folder
list_log=$(ls -- *[.log])
for item in $list_log; do
    cat "hasil_MOL.txt"
    echo "$item"
    cat "$item" | grep -oP "(?<=source: /opt/raw_data/)[^ ]*" | tr '\n' ',' >> "hasil_MOL.txt" #search nama OSS, tech nya + vendornya , dan trim newline menjadi "," supaya mudah dibuat csv file
    cat "$item" | grep -oP "(?<=Finishing loading network model to DB.Number of records loaded )[^ ]*" >> "hasil_MOL.txt" #search nilai MOLoad di OSS tersebut
    cp "hasil_MOL.txt" ..
done
)

## mensortir file nya sesuai teknologi, yang 2g, 3g dan 4g
(grep "2g" hasil_MOL.txt > MOL_2G.csv
grep "3g" hasil_MOL.txt > MOL_3G.csv
grep "4g" hasil_MOL.txt > MOL_4G.csv
)

##aktifitas selesai, saatnya bersih bersih
rm --recursive MOL
