#!/bin/bash
tanggal=`date "+%d_%b_%Y"`; jam=`date "+%T"`
pchr_dir="/export/home/sysm/ftproot/PCHR"
pchr_dir_jabo26="/export/home/sysm/ftproot/PCHR_26"

ambil_data_pchr() {

ftp -n $2 > "$1.txt" << EOT
ascii
user $3 $4
prompt
cd $5
ls -lt
bye
EOT
}

(mkdir "pchr"
cd "pchr" || return
# Struktur Parameter =>  OSS    IP    username    password        folderPCHR
#                                       $1     $2         $3              $4                     $5

ambil_data_pchr "Bali" 10.2.160.112 ftptest Telkomsel#2 $pchr_dir
ambil_data_pchr "Central_Java" 10.52.204.81 ftpuser Changeme_123 $pchr_dir
ambil_data_pchr "Central_Sumatra" 10.52.205.71 ftptest Telkomsel#1 $pchr_dir
ambil_data_pchr "East_Java" 10.52.209.199 ftptest Telkomsel#1 $pchr_dir
ambil_data_pchr "Jabodetabek_18" 10.2.160.52 ftpuser Changeme_123 $pchr_dir
ambil_data_pchr "Jabodetabek_23" 10.52.207.200 ftpuser Changeme_123 $pchr_dir
ambil_data_pchr "Jabodetabek_26" 10.52.207.200 ftpuser Changeme_123 $pchr_dir_jabo26
ambil_data_pchr "North_Sumatera" 10.52.204.201 ftptest Telkomsel#1 $pchr_dir
ambil_data_pchr "Nusa_Tenggara" 10.54.30.75 ftptest Telkomsel#1 $pchr_dir
ambil_data_pchr "South_Sumatra" 10.52.208.202 ftptest Telkomsel#2 $pchr_dir
ambil_data_pchr "West_Java" 10.165.2.70 ftptest Telkomsel#2 $pchr_dir
)

(
cd database/ || return
(echo "Diperiksa Pada ,$tanggal" ; echo "Jam ,$jam" ; echo " ";echo "OSS,RNC,Status" ) >> "file_check.csv"
for list in $(cat list_database.txt) ; do
echo "Sedang mengecek OSS $list"
	for item in $(cat $list) ; do
	echo "Lagi check $item"
	echo "$list" | tr '\n' ',' >> "file_check.csv"       #Kolom OSS
	echo "$item" | tr '\n' ',' >> "file_check.csv"     #Kolom RNC
	grep "$item" "../pchr/$list"  ; if [ $? -eq 0 ] ; then echo "ada"  >> "file_check.csv" ; else echo "tidak ditemukan" >> "file_check.csv"; fi #Kolom Status
	done
done
echo "Mencocokan file selesai, saatnya save file ke folder yang diinginkan"
mv "file_check.csv" ../"pchr_oss_check_$tanggal.csv"
)

##aktifitas selesai, saatnya simpen file penting dan bersih bersih
simpen_file=$(zenity --file-selection --directory --title="Pilih tempat simpan file" --filename=/home/iqbal/Kerja/imobi/task/Operation/log/)
zip -r pchr_oss_check.zip pchr/
mv "pchr_oss_check_$tanggal.csv" pchr_oss_check.zip "$simpen_file" #pindahin file csv ke folder pilihan pengguna
rm --recursive pchr #bersihin folder tempat ekstrak file, dll

