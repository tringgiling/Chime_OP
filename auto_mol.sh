#!/bin/bash

mkdir MOL
pilih_file_MOL=$(zenity --file-selection --file-filter='ZIP files (zip) | *.zip' --title="Pilih File Parent MOL nya" --filename=/home/iqbal/Kerja/imobi/task/Operation/log/) #nyari file yang mau di proses
cp "$pilih_file_MOL" MOL/

## buka log di folder khusus
(cd MOL/ || return #return buat antisipasi kalau gagal masuk folder
unzip -- *.zip
gzip -d -- *.gz #buka bungkus log yang  berekstensi .gz
)

## baca file log di folder khusus, grep yang dibutuhkan, hasilnya dirangkum di folder utama
(cd MOL/ || return #return buat antisipasi kalau gagal masuk folder
list_log=$(ls -- *[.log])
for item in $list_log; do
    cat "hasil_MOL.txt"
    echo "$item"
    grep -oP "(?<=source: /opt/raw_data/)[^ ]*" "$item" | tr '\n' ',' >> "hasil_MOL.txt" #search nama OSS, tech nya + vendornya , dan trim newline menjadi "," supaya mudah dibuat csv file
    grep -oP "(?<=Finishing loading network model to DB.Number of records loaded )[^ ]*" "$item" >> "hasil_MOL.txt" || if [ $? -eq 1 ] ; then echo "fail" >> "hasil_MOL.txt" ; else return; fi #search nilai MOLoad di OSS tersebut
done
cp "hasil_MOL.txt" ..
)

## mensortir file nya sesuai teknologi, yang 2g, 3g dan 4g
(grep "2g" hasil_MOL.txt | sort > MOL.csv ; echo " " >> MOL.csv
grep "3g" hasil_MOL.txt  | sort >> MOL.csv ; echo " " >> MOL.csv
grep "4g" hasil_MOL.txt  | sort >> MOL.csv
)

##aktifitas selesai, saatnya bersih bersih
simpen_file=$(zenity --file-selection --directory --title="Pilih tempat simpan file" --filename=/home/iqbal/Kerja/imobi/task/Operation/log/)
mv MOL.csv hasil_MOL.txt "$simpen_file" #pindahin file csv ke folder pilihan pengguna
rm --recursive MOL
