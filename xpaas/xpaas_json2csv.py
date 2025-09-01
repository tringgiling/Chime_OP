import pandas as pd
import json

file='om_hep.json'
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
tabel_akhir.to_csv('iqbal_2.csv',index=False)