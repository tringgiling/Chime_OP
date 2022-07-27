#!/bin/bash

mkdir NL
pilih_file_NL=$(zenity --file-selection --file-filter='ZIP files (zip) | *.zip' --title="Pilih File Parent NL nya" --filename=/home/iqbal/Kerja/imobi/task/Operation/log/) #nyari file yang mau di proses
cp "$pilih_file_NL" NL/

## buka log di folder khusus
(cd NL/ || return #return buat antisipasi kalau gagal masuk folder
unzip -- *.zip
gzip -d -- *.gz #buka bungkus log yang  berekstensi .gz
)

## Ambil tanggal Log NL untuk dijadikan nama file output nantinya
tanggal_NL=$(ls NL/ | grep -oP "(?<=optserver.)[^_]*" | head -n 1)

## baca file log di folder khusus, grep yang dibutuhkan, hasilnya dirangkum di folder utama
(cd NL/ || return #return buat antisipasi kalau gagal masuk folder
list_log=$(ls -- *[.log])

for item in $list_log; do

	#Menginfokan File log mana yang sedang diolah
    echo "Sedang memproses $item"

	#Membaca 50 Baris pertama file, lalu meng grep Nama oss + vendor dilanjut trim newline menjadi "," supaya mudah dibuat csv file
    head -n 50 "$item" | grep -oP "(?<=Path /opt/raw_data/)[^ ]*" | tr '\n' ',' >> "hasil_NL.txt"
    
    #search nilai NLoad di OSS tersebut, ambil angkanya aja
    egrep -o "[0-9]{1,6} file-based networks were built" "$item" | egrep -o "[0-9]{1,6}" | tr '\n' ',' >> "hasil_NL.txt" || if [ $? -eq 1 ] ; then echo "fail" | tr '\n' ',' >> "hasil_NL.txt" ; else return; fi 
    
    #Membaca 20 Baris terakhir File, dialnjut search nilai MOLoad di OSS/EMS tersebut
    tail -n 20  "$item" | grep -oP "(?<=completed with the following status: )[^ ]*" | tr '\n' ',' >> "hasil_NL.txt" || if [ $? -eq 1 ] ; then echo "belum beres" | tr '\n' ',' >> "hasil_NL.txt" ; else return; fi
	
	### Ini ngga wajib sih, cuman make sure aja kalau semua data sector itu udah terload sesuai physical data nya
	(
	#Nyari nomor baris yang bagian data nilai sector, berapa physical data yang di load, dst. supaya 3 grep di bawah bisa lebih efisien
	baris_awal=$(grep -n "sectors were located by" "$item" | cut -d: -f 1 | head -n 1); baris_akhir="$(($baris_awal + 20))"
	
	#Nge grep semua baris yang ada nilai sector, terus dijumlahin semua
	sector=$(sed ''"$baris_awal"','"$baris_akhir"'!d' "$item" | egrep -o "[0-9]{0,6} sectors were located by" "$item" | egrep -o "[0-9]{0,6}") ; arr=( $sector ) ; echo "$((${arr[@]/%/+}0))" | tr '\n' ','  >> "hasil_NL.txt"

	# Nge grep jumlah sector yang gagal nge load physical data
	sed ''"$baris_awal"','"$baris_akhir"'!d' "$item" | grep -oP "(?<=Failed to find physical data for )[^ ]*" | tr '\n' ','  >> "hasil_NL.txt"
	
	# Nge grep jumlah sector yang gagal nge load RET data
	sed ''"$baris_awal"','"$baris_akhir"'!d' "$item" | grep -oP "(?<=Failed to find Matched Ret for )[^ ]*" >> "hasil_NL.txt"
	)
	
	#finishing terakhir buat memangkas data yang ngga diperlukan
	sed -E '1s/\[.*\]\,0\,//' hasil_NL.txt > hasil_NL_final.txt
done
echo "Selesai"
cp "hasil_NL_final.txt" ../hasil_NL.txt)

#Urutkan sesuai teknologi dan OSS, lalu simpan hasilnya dalam bentuk csv
(echo "Region Path,Jumlah File-based NL,Status task,Jumlah Sektor,Total Failed Physical (sector),Total Failed RET (Sector)";
grep "Ran07" hasil_NL.txt
grep "Ran08" hasil_NL.txt ; echo " " # space kosong buat Ran 09
grep "Ran10" hasil_NL.txt
grep "Ran11" hasil_NL.txt ) > "NL_Ericsson_$tanggal_NL.csv"

##aktifitas selesai, saatnya simpen file penting dan bersih bersih
simpen_file=$(zenity --file-selection --directory --title="Pilih tempat simpan file" --filename="$pilih_file_NL")
mv "NL_Ericsson_$tanggal_NL.csv" "hasil_NL.txt" "$simpen_file" #pindahin file csv ke folder pilihan pengguna
rm --recursive NL #bersihin folder tempat ekstrak file NL
