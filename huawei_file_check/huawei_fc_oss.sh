#!/bin/bash
tanggal=`date "+%d_%b_%Y"`; jam=`date "+%T"`  #buat detail kapan pemeriksaan dilakukan
cm_dir=/export/home/sysm/ftproot/TimerTask/CFGMML

#Function untuk ambil data CFGMML di server OSS
ambil_data_cm() {
echo "Lagi berkunjung ke OSS $1"
ftp -n $2 > "$1.txt" << EOT
ascii
user $3 $4
prompt
cd $5
ls -lt
bye
EOT
}

#proses ambil data CFGMML di OSS
(
mkdir "cfgmml" 
cd cfgmml/ || return

# Struktur Parameter =>  OSS    IP    username    password        folder_CFGMML
#                                      $1     $2         $3              $4                     $5

ambil_data_cm "Bali" 10.212.82.4 ftptest T3lk0ms3l#2 $cm_dir
ambil_data_cm "Central_Java" 10.212.86.5 ftpuser Changeme_123 $cm_dir
ambil_data_cm "Central_Sumatera" 10.212.83.57 ftptest T3lk0ms3l#2 $cm_dir
ambil_data_cm "East_Java" 10.212.85.5 ftptest T3lk0ms3l#2 $cm_dir
ambil_data_cm "Jabodetabek_18" 10.168.194.5 ftptest T3lk0ms3l#2 $cm_dir
ambil_data_cm "Jabodetabek_23" 10.168.194.48 ftptest T3lk0ms3l#2 $cm_dir
ambil_data_cm "Jabodetabek_26" 10.168.194.100 ftptest T3lk0ms3l#2 $cm_dir
ambil_data_cm "North_Sumatera" 10.212.83.83 ftptest T3lk0ms3l#2 $cm_dir
ambil_data_cm "Nusa_Tenggara" 10.212.82.32 ftptest T3lk0ms3l#2 $cm_dir
ambil_data_cm "South_Sumatera" 10.212.83.5 ftpuser Changeme_123 $cm_dir
ambil_data_cm "West_Java" 10.168.197.5 ftptest T3lk0ms3l#2 $cm_dir
)

## Pengelompokan sesuai MBSC/RNC per oss 
( cd cfgmml/ || return

kelompok_oss()
{
	echo "sedang mengelompokan OSS $1"
	grep "MBSC" "$1.txt" >> "2G_$1.txt" 
	grep "RNC" "$1.txt" >> "3G_$1.txt"
}

kelompok_oss "Jabodetabek_23"
kelompok_oss "Nusa_Tenggara"
kelompok_oss "North_Sumatera"
kelompok_oss "East_Java"
kelompok_oss "South_Sumatera"
kelompok_oss "Jabodetabek_26" 
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
cd database/ || return
(echo "Diperiksa Pada ,$tanggal" ; echo "Jam ,$jam" ; echo " ";echo "OSS,BSC/RNC,Part of 66 City?,Status OSS,Time_Stamp OSS" ) >> "file_check.csv"
for list in $(cat list_database.txt) ; do
echo "Sedang mengecek OSS $list"
	for item in $(cat $list) ; do
	echo "Lagi check $item"
	echo "$list" | sed 's/.txt//g' | sed 's/_non_66//g' |tr "\n" "," >> "file_check.csv"       #Kolom OSS
	echo "$item" | tr '\n' ',' >> "file_check.csv"     #Kolom BSC/RNC
	(echo "$list" | grep -q "non_66";  if [ $? -eq 1 ] ; then echo "Yes" | tr '\n' ',' ; else echo "No" | tr '\n' ',' ; fi ) >> "file_check.csv" # Kolom Part 66 City
	clear_list=$(echo "$list" | sed 's/_non_66//g') #pengaman untuk proses membanding database dengan file non 66 city
	grep "$item"_ "../cfgmml/$clear_list"  ; if [ $? -eq 0 ] ; then echo "ada" | tr '\n' ',' >> "file_check.csv" ; else echo "tidak ditemukan" | tr '\n' ',' >> "file_check.csv"; fi #Kolom Status
	(grep -oP "(?<="$item"_)[^ ][0-9]{1,8}"  "../cfgmml/$clear_list" || if [ $? -eq 1 ] ; then echo "-"  ; else return; fi) | head -1>> "file_check.csv" #Kolom Time_stamp
	done
done
echo "Mencocokan file selesai, saatnya save file ke folder yang diinginkan"
mv "file_check.csv" ../"file_oss_check_$tanggal.csv"
)

##aktifitas selesai, saatnya simpen file penting dan bersih bersih
simpen_file=$(zenity --file-selection --directory --title="Pilih tempat simpan file" --filename=/home/iqbal/Kerja/imobi/task/Operation/log/)
zip -r file_oss_check.zip cfgmml/ file_check.txt
mv file_oss_check_$tanggal.csv file_oss_check.zip "$simpen_file" #pindahin file csv ke folder pilihan pengguna
rm --recursive cfgmml  #bersihin folder tempat ekstrak file, dll
