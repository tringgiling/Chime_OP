import pandas as pd
import json
import tkinter as tk
from tkinter import filedialog
from pathlib import Path

### Milih file json ###
tipe_file = [("JSON Files", "*.json"), ("All Files", "*.*")]
pilih_file_json = Path(filedialog.askopenfilename(filetypes=tipe_file,title="Pilih file json hasil xpaas nya"))
print ('File json : ' + str(pilih_file_json))

###

file= pilih_file_json
with open(file,'r') as f:
    data=json.load(f)
    
hasil_akhir = []


for item in data['elements']:
    cell=item['_cellId']
    for result_per_granularity in item['data_points']:
        result_from=result_per_granularity['from']
        result_to=result_per_granularity['to']
        kpi_per_granularity = result_per_granularity['values']
        baris = {}
        baris.update({"Cell_id" : cell})
        baris.update({"from" : result_from})
        baris.update({"to" : result_to})
        
        for kpi in kpi_per_granularity:
            nilai_kpi = kpi_per_granularity[kpi]['value']
            baris.update({kpi : nilai_kpi})
        hasil_akhir.append(baris)

print(len(hasil_akhir))
tabel_akhir = pd.DataFrame(hasil_akhir)
print(tabel_akhir)

simpen_file = filedialog.asksaveasfilename(filetypes=[('CSV Files', '*.csv'), ('All Files', '*.*')])
tabel_akhir.to_csv(simpen_file,index=False)
print ('Output csv ada di : ' + simpen_file)
#input ("Press any key to exit : ")