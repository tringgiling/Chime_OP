#!/bin/bash


ambil_data_pchr() {
ftp -n $2 > "$1.txt" << EOT
ascii
user $3 $4
prompt
cd /export/home/sysm/ftproot/PCHR
ls
bye
EOT
}

(cd test
# Struktur Parameter =>  OSS    IP    username    password
#                                       $1     $2         $3              $4
ambil_data_pchr "Bali" 10.2.160.112 ftptest Telkomsel#2
ambil_data_pchr "Central_Java" 10.52.204.81 ftpuser Changeme_123
ambil_data_pchr "Central_Sumatra" 10.52.205.71 ftptest Telkomsel#1
ambil_data_pchr "East_Java" 10.52.209.199 ftptest Telkomsel#1
ambil_data_pchr "Jabodetabek_18" 10.2.160.52 ftpuser Changeme_123
ambil_data_pchr "Jabodetabek_2" 10.52.207.200 ftpuser Changeme_123
ambil_data_pchr "North_Sumatera" 10.52.204.201 ftptest Telkomsel#1
ambil_data_pchr "Nusa_Tenggara" 10.54.30.75 ftptest Telkomsel#1
ambil_data_pchr "South_Sumatra" 10.52.208.202 ftptest Telkomsel#2
ambil_data_pchr "West_Java" 10.52.209.199 ftptest Telkomsel#1
)
