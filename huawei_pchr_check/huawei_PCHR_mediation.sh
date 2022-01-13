#!/bin/bash
tanggal=`date "+%d_%b_%Y"`; jam=`date "+%T"`  #buat detail kapan pemeriksaan dilakukan

####Khusus SOCKS Proxy Linux
#default_ip_socks="192.168.42.129"		#Khusus vpn iqbal
#default_port_socks="1080"					#Khusus vpn iqbal
#echo -n "Masukan IP SOCKS Proxy untuk terhubung ke mediation server, default ($default_ip_socks) : "
#read -r ip_socks; if [[ -z $ip_socks ]] ; then ip_socks="$default_ip_socks" ; else echo "IP Socks = $ip_socks"; fi
#echo -n "Masukan Port SOCKS proxy, default ($default_port_socks) : "
#read -r port_socks ; if [[ -z $port_socks ]] ; then port_socks="$default_port_socks" ; else echo "Port Socks = $port_socks"; fi

#sftp -oProxyCommand="netcat -v -x $ip_socks:$port_socks %h %p" sse@10.62.101.88 22 > "file_check.txt" << EOF
####

sftp sse@10.62.101.88 22 > "file_check.txt" << EOF
ls /opt/nfs-data/shares/raw_data/huawei/pchr/oss_Bali/3g
ls /opt/nfs-data/shares/raw_data/huawei/pchr/oss_East_Java/3g
ls /opt/nfs-data/shares/raw_data/huawei/pchr/oss_South_Sumatra/3g
ls /opt/nfs-data/shares/raw_data/huawei/pchr/oss_Central_Java/3g
ls /opt/nfs-data/shares/raw_data/huawei/pchr/oss_Jabodetabek_18/3g
ls /opt/nfs-data/shares/raw_data/huawei/pchr/oss_North_Sumatera/3g
ls /opt/nfs-data/shares/raw_data/huawei/pchr/oss_West_Java/3g
ls /opt/nfs-data/shares/raw_data/huawei/pchr/oss_Central_Sumatra/3g
ls /opt/nfs-data/shares/raw_data/huawei/pchr/oss_Jabodetabek_23/3g
ls /opt/nfs-data/shares/raw_data/huawei/pchr/oss_Jabodetabek_26/3g
ls /opt/nfs-data/shares/raw_data/huawei/pchr/oss_Nusa_Tenggara/3g
bye
EOF

## Pengelompokan sesuai MBSC/RNC dilanjut pengelompokan sesuai OSS
( mkdir "pchr" 
grep "RNC" "file_check.txt" > "pchr/file_check_RNC.txt"
cd pchr/ || return

kelompok_oss()
{
	echo "sedang mengelompokan OSS $1"
	grep "$1" file_check_RNC.txt >> "$1.txt"
}

kelompok_oss "Jabodetabek_2"
kelompok_oss "Nusa_Tenggara"
kelompok_oss "North_Sumatera"
kelompok_oss "East_Java"
kelompok_oss "South_Sumatra" 
kelompok_oss "Central_Java"
kelompok_oss "Jabodetabek_18"
kelompok_oss "Bali"
kelompok_oss "West_Java"
kelompok_oss "Central_Sumatra"
kelompok_oss "South_Sumatra"
kelompok_oss "North_Sumatera"
)

## Mencocokan antara database dan pchr, bila ada yang kurang, lempar ke file csv untuk dilaporkan
(
cd database/ || return
(echo "Diperiksa Pada ,$tanggal" ; echo "Jam ,$jam" ; echo " ";echo "OSS,BSC/RNC,Status" ) >> "file_check.csv"
for list in $(cat list_database.txt) ; do
echo "Sedang mengecek OSS $list"
	for item in $(cat $list) ; do
	echo "Lagi check $item"
	echo "$list" | tr '\n' ',' >> "file_check.csv"       #Kolom OSS
	echo "$item" | tr '\n' ',' >> "file_check.csv"     #Kolom BSC/RNC
	grep "$item" "../pchr/$list"  ; if [ $? -eq 0 ] ; then echo "ada"  >> "file_check.csv" ; else echo "tidak ditemukan" >> "file_check.csv"; fi #Kolom Status
	done
done
echo "Mencocokan file selesai, saatnya save file ke folder yang diinginkan"
mv "file_check.csv" ../"pchr_check_$tanggal.csv"
)

##aktifitas selesai, saatnya simpen file penting dan bersih bersih
simpen_file=$(zenity --file-selection --directory --title="Pilih tempat simpan file" --filename=/home/iqbal/Kerja/imobi/task/Operation/log/)
zip -r pchr_check.zip pchr/ file_check.txt
mv pchr_check_$tanggal.csv pchr_check.zip "$simpen_file" #pindahin file csv ke folder pilihan pengguna
rm --recursive pchr file_check.txt #bersihin folder tempat ekstrak file, dll

