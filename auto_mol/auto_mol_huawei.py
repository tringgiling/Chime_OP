import os
import tkinter as tk
import shutil
import gzip
import re
from tkinter import filedialog #buat pilih file MOL
from pathlib import Path
from shutil import copy, rmtree

## Kumpulan variabel
folder_proses = "MOL"


## pilih file parent MOL dan di copy in ke sini
os.mkdir(folder_proses)
root = tk.Tk()
root.withdraw()
pilih_file_parent = filedialog.askopenfilename()
nama_file_parent = Path(pilih_file_parent).stem + ".zip"
copy (pilih_file_parent, folder_proses + "/" + nama_file_parent)

## unzip file parent 
shutil.unpack_archive( folder_proses + "/" + nama_file_parent, folder_proses)
os.remove( folder_proses + "/" + nama_file_parent)

## Mengambil Time stamp dari file MOL yang di proses
list_file = os.listdir(folder_proses)
time_stamp = "".join(re.findall(r'(?<=optserver.)[^_]*',list_file[0]))

## decompress file gzip di folder MOL
for file_gzip in os.listdir(folder_proses):
	with gzip.open(folder_proses + "/" + file_gzip , 'rb') as f_in:
		with open(folder_proses + "/" + Path(file_gzip).stem , 'wb') as f_out:
			shutil.copyfileobj(f_in, f_out)
	os.remove( folder_proses + "/" + file_gzip)

## baca file log dan mencari informasi yang dibutuhkan
list_data_4G_MOL = []
list_data_2G_MOL = []
for daftar_file in os.listdir(folder_proses):
	
	print ("Sedang memproses : " + daftar_file)
	
	for baris in open (folder_proses + "/" +daftar_file, "r"):
		nama_oss = re.findall(r'(?<=source: /opt/raw_data/)[^ \n ]*',baris)
		jumlah_file_terproses = re.findall(r'(?<=Finishing loading network model to DB.Number of records loaded )[^\n ]*',baris)
		
		
		if len(nama_oss) > 0 :
			simpan_nama_oss = ("".join(nama_oss)) #nama oss di rubah ke string dulu, baru di simpen ke variabl
			
		elif len (jumlah_file_terproses) > 0 :
			
			if "4g" in simpan_nama_oss:
				list_data_4G_MOL.append(simpan_nama_oss +"%" + "".join(jumlah_file_terproses)) #% = buat pembatas
				
			elif "2g" in simpan_nama_oss:
				list_data_2G_MOL.append(simpan_nama_oss +"%" + "".join(jumlah_file_terproses)) #% = buat pembatas
			
			else:
				print ("Source tidak diketahui")
		
	open (folder_proses + "/" +daftar_file, "r").close()

## urutkan sesuai alfabet 
list_data_2G_MOL.sort()
list_data_4G_MOL.sort()

## write ke csv file
file_output = open(folder_proses + "_" + time_stamp + ".csv","a")
#file_output = open(folder_proses + "_"  + ".csv","a")
file_output.write("Nama OSS,Jumlah File diproses\n")

for item in list_data_4G_MOL :
	file_output.write(item.replace("%", ",") + "\n")

file_output.write("\n") #new line untuk misahin antara bagian 4G dan 2G

for item in list_data_2G_MOL :
	file_output.write(item.replace("%", ",") + "\n")

file_output.close()
shutil.rmtree(folder_proses)


