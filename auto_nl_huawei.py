import os
import tkinter as tk
import shutil
import gzip
import re
from tkinter import filedialog #buat pilih file NL
from pathlib import Path
from shutil import copy, rmtree

## Kumpulan variabel
folder_proses = "NL_Huawei"


## pilih file parent NL dan di copy in ke sini
os.mkdir(folder_proses)
root = tk.Tk()
root.withdraw()
pilih_file_parent = filedialog.askopenfilename()
nama_file_parent = Path(pilih_file_parent).stem + ".zip"
copy (pilih_file_parent, folder_proses + "/" + nama_file_parent)

## unzip file parent 
shutil.unpack_archive( folder_proses + "/" + nama_file_parent, folder_proses)
os.remove( folder_proses + "/" + nama_file_parent)

## Mengambil Time stamp dari file NL yang di proses
list_file = os.listdir(folder_proses)
time_stamp = "".join(re.findall(r'(?<=optserver.)[^_]*',list_file[0]))

## decompress file gzip di folder NL
for file_gzip in os.listdir(folder_proses):
	with gzip.open(folder_proses + "/" + file_gzip , 'rb') as f_in:
		with open(folder_proses + "/" + Path(file_gzip).stem , 'wb') as f_out:
			shutil.copyfileobj(f_in, f_out)
	os.remove( folder_proses + "/" + file_gzip)

## baca file log dan mencari informasi yang dibutuhkan
list_data_4G= []
list_data_2G= []
for daftar_file in os.listdir(folder_proses):
	
	print ("Sedang memproses : " + daftar_file)
	list_jumlah_sector = []    #khusus untuk menampung regex jumlah sector sebelum dijumlahkan
	
	for baris in open (folder_proses + "/" +daftar_file, "r"):
		
		##Mecari "item" sesuai pattern yang cocok
		regex_nama_oss = re.findall(r'(?<=Path /opt/raw_data/)[^ \n ]*', baris)
		regex_jumlah_file_terproses = re.findall(r'[0-9]{1,6}(?= file-based networks were built)',baris)
		regex_status_task = re.findall(r'(?<=completed with the following status: )[^ \n]*',baris)
		regex_jumlah_sector = re.findall(r'[0-9]{1,6}(?= sectors were located by)',baris)
		regex_missing_sector = re.findall(r'(?<=Failed to find physical data for )[^ ]*',baris)
		regex_missing_RET = re.findall(r'(?<=Failed to find Matched Ret for )[^ ]*',baris)
		
		## Item yang tadi ditemukan di rubah ke bentuk string (kalau list susah diolah soalnya)
		if len (regex_nama_oss) > 0 :
			nama_oss = "".join(regex_nama_oss) 
		
		if len (regex_jumlah_file_terproses) > 0 :
			jumlah_file_terproses = "".join(regex_jumlah_file_terproses)
	
		if len (regex_status_task) > 0 :
			status_task = "".join(regex_status_task)
		
		if len (regex_jumlah_sector) > 0 :
			list_jumlah_sector.append(int("".join(regex_jumlah_sector)))
	
		if len (regex_missing_sector) > 0 :
			missing_sector = "".join(regex_missing_sector)
	
		if len (regex_missing_RET) > 0 :
			missing_RET = "".join(regex_missing_RET)
		
		open (folder_proses + "/" +daftar_file, "r").close()


	jumlah_sector = sum(list_jumlah_sector) #khusus menjumlahkan total sector yg ditemukan via findall
	
	## selesai for-loop regex, masukin hasil nya ke list sesuai teknologi
	if "4g" in nama_oss :
		list_data_4G.append(nama_oss +"%"+ jumlah_file_terproses +"%"+ status_task +"%"+ str(jumlah_sector) +"%"+ missing_sector +"%"+ missing_RET ) #% = buat pembatas
		
	elif "2g" in nama_oss :
		list_data_2G.append(nama_oss +"%"+ jumlah_file_terproses +"%"+ status_task +"%"+ str(jumlah_sector) +"%"+ missing_sector +"%"+ missing_RET ) #% = buat pembatas
	
	else :
		print ("Sumber Tidak diketahui")
		
## Mengurutkan sesuai alfabet
list_data_4G.sort()
list_data_2G.sort()

## write ke csv file
file_output = open(folder_proses + "_" + time_stamp + ".csv","a")
file_output.write("Region Path,Jumlah File-based NL,Status task,Jumlah Sektor,Total Failed Physical (sector),Total Failed RET (Sector)\n")

for item in list_data_4G :
	file_output.write(item.replace("%", ",") + "\n")

file_output.write("\n") #new line untuk misahin antara bagian 4G dan 2G

for item in list_data_2G :
	file_output.write(item.replace("%", ",") + "\n")

file_output.close()
shutil.rmtree(folder_proses)

