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
	
	#Menginfokan File log mana yang sedang diolah
    echo "Sedang memproses $item"
    
    #Membaca 5000 Baris pertama file, lalu meng grep Nama oss + vendor dilanjut trim newline menjadi "," supaya mudah dibuat csv file
    #Gara gara zte jadi harus set ke 5000, padahal kalau huawei pure cuma butuh 500 first line
    head -n 5000 "$item" | grep -oP "(?<=source: /opt/raw_data/)[^ ]*"  | tr '\n' ',' >> "hasil_MOL.txt"
    
    #Membaca 10 Baris terakhir File, dialnjut search nilai MOLoad di OSS/EMS tersebut
    tail -n 10 "$item" | grep -oP "(?<=Finishing loading network model to DB.Number of records loaded )[^ ]*"  >> "hasil_MOL.txt" || if [ $? -eq 1 ] ; then echo "fail" >> "hasil_MOL.txt" ; else return; fi 
done
cp "hasil_MOL.txt" ..
)

## mensortir file nya sesuai teknologi dan diurut sesuai OSS, disimpan dalam bentuk file csv
(grep "4g" hasil_MOL.txt | sort  ; echo " "
grep "3g" hasil_MOL.txt  | sort  ; echo " "
grep "2g" hasil_MOL.txt  | sort ) > MOL.csv


##aktifitas selesai, saatnya pindahin file penting dan bersih bersih
simpen_file=$(zenity --file-selection --directory --title="Pilih tempat simpan file" --filename="$pilih_file_MOL")
mv MOL.csv hasil_MOL.txt "$simpen_file" #pindahin file csv ke folder pilihan pengguna
rm --recursive MOL
