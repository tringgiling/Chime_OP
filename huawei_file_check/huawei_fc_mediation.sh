#!/bin/bash
default_ip_socks="192.168.42.129"		#Khusus vpn iqbal
default_port_socks="1080"					#Khusus vpn iqbal

echo -n "Masukan IP SOCKS Proxy untuk terhubung ke mediation server, default ($default_ip_socks) : "
read -r ip_socks; if [[ -z $ip_socks ]] ; then ip_socks="$default_ip_socks" ; else echo "IP Socks = $ip_socks"; fi
echo -n "Masukan Port SOCKS proxy, default ($default_port_socks) : "
read -r port_socks ; if [[ -z $port_socks ]] ; then port_socks="$default_port_socks" ; else echo "Port Socks = $port_socks"; fi

sftp -oProxyCommand="netcat -v -x $ip_socks:$port_socks %h %p" sse@10.62.101.88 22 > "file_check.txt" << EOF
ls /opt/nfs-data/shares/raw_data/huawei/sd/2g/oss_Bali
ls /opt/nfs-data/shares/raw_data/huawei/sd/2g/oss_East_Java
ls /opt/nfs-data/shares/raw_data/huawei/sd/2g/oss_South_Sumatera
ls /opt/nfs-data/shares/raw_data/huawei/sd/2g/oss_Central_Java
ls /opt/nfs-data/shares/raw_data/huawei/sd/2g/oss_Jabodetabek_18
ls /opt/nfs-data/shares/raw_data/huawei/sd/2g/oss_North_Sumatera
ls /opt/nfs-data/shares/raw_data/huawei/sd/2g/oss_West_Java
ls /opt/nfs-data/shares/raw_data/huawei/sd/2g/oss_Central_Sumatera
ls /opt/nfs-data/shares/raw_data/huawei/sd/2g/oss_Jabodetabek_23
ls /opt/nfs-data/shares/raw_data/huawei/sd/2g/oss_Nusa_Tenggara
ls /opt/nfs-data/shares/raw_data/huawei/sd/3g/oss_Bali
ls /opt/nfs-data/shares/raw_data/huawei/sd/3g/oss_East_Java
ls /opt/nfs-data/shares/raw_data/huawei/sd/3g/oss_South_Sumatera
ls /opt/nfs-data/shares/raw_data/huawei/sd/3g/oss_Central_Java
ls /opt/nfs-data/shares/raw_data/huawei/sd/3g/oss_Jabodetabek_18
ls /opt/nfs-data/shares/raw_data/huawei/sd/3g/oss_North_Sumatera
ls /opt/nfs-data/shares/raw_data/huawei/sd/3g/oss_West_Java
ls /opt/nfs-data/shares/raw_data/huawei/sd/3g/oss_Central_Sumatera
ls /opt/nfs-data/shares/raw_data/huawei/sd/3g/oss_Jabodetabek_23
ls /opt/nfs-data/shares/raw_data/huawei/sd/3g/oss_Nusa_Tenggara
EOF

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
cd database/ || return
for list in $(cat list_database.txt) ; do
echo "Sedang mengecek OSS $list"
	for item in $(cat $list) ; do
	echo "Lagi check $item"
	echo "$list" | tr '\n' ',' >> "file_check.csv"
	echo "$item" | tr '\n' ',' >> "file_check.csv"
	grep "$item"_ "../cfgmml/$list"  ; if [ $? -eq 0 ] ; then echo "aman" >> "file_check.csv" ; else echo "tidak ditemukan" >> "file_check.csv"; fi #search data BSC/RNC dari file database, dicocokan dengan yang ada di CFGMML
	done
done
echo "Mencocokan file selesai, saatnya save file ke folder yang diinginkan"
mv "file_check.csv" ..
)

##aktifitas selesai, saatnya simpen file penting dan bersih bersih
simpen_file=$(zenity --file-selection --directory --title="Pilih tempat simpan file" --filename=/home/iqbal/Kerja/imobi/task/Operation/log/)
zip -r file_check.zip cfgmml/ file_check.txt
mv file_check.csv file_check.zip "$simpen_file" #pindahin file csv ke folder pilihan pengguna
rm --recursive cfgmml file_check.txt #bersihin folder tempat ekstrak file, dll

