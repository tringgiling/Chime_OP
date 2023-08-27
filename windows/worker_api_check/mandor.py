import json
import datetime
import subprocess

import sys #buat import pandas di local
sys.path.append(r"C:\Users\22345746\Chime_OP\windows\python library\installed\pandas")
import pandas as pd


def MANDOR(Environment):
	if Environment == "PROD":
		IP_WLM = "10.62.101.62"

	elif Environment == "PREPROD":
		IP_WLM = "10.62.101.157"

	elif Environment == "UAT":
		IP_WLM = "10.62.101.161"

	elif Environment == "LAB":
		IP_WLM = "10.62.101.164"


	hasil_cek_ke_wlm_api = WLM_API_Check (IP_WLM)
	hasil_olah_data_json = WLM_JSON_DATA_PROCESSOR(hasil_cek_ke_wlm_api)

	print ("==========  " + Environment + "  ==============")
	print (pd.DataFrame(hasil_olah_data_json,columns=["Worker Name", "Start Date", "Start Time", "Last Seen", "Last Seen Time"]))

	#cetak log
	WLM_LOGGER (hasil_olah_data_json,Environment)




def WLM_API_Check (WLM_IP):
	#Ambil Data worker dari WLM API
	wlm_respon_json = subprocess.check_output(["curl", "-X", "GET", "http://%s:9090/wlm/tasks/servers" % WLM_IP, "-H",  "accept: */*"])
	
	###convert dari json ke python dictionary
	#jadi karena hasil dari wlm api itu banyak, jadi dikelompokin per worker
	# 1 worker itu di json nya {}, nah ini di convert jadi 1 dictionary sama python
	# kumpulan dictionary itu digabungin jadi list
	
	wlm_respon_list_dict = json.loads(wlm_respon_json)
	return (wlm_respon_list_dict)


def WLM_JSON_DATA_PROCESSOR(WLM_JSON_DATA):
	#tampilin data spesifik dari semua worker pake for loop
	WLM_STRING_DATA = [] 
	for worker in range(len(WLM_JSON_DATA)) :
		if WLM_JSON_DATA[worker]['startedAt'] == 0 : #Dead Worker
			json_data_per_1_worker = (WLM_JSON_DATA[worker]['hostname'],
			"Dead",
			"Dead",
			datetime.datetime.fromtimestamp(WLM_JSON_DATA[worker]['lastSeen']/1000).strftime("%d/%m/%y"),
			datetime.datetime.fromtimestamp(WLM_JSON_DATA[worker]['lastSeen']/1000).strftime("%H:%M:%S")
			)	

		
		
		
		else: 
			json_data_per_1_worker = (WLM_JSON_DATA[worker]['hostname'],
			datetime.datetime.fromtimestamp(WLM_JSON_DATA[worker]['startedAt']/1000).strftime("%d/%m/%y"),
			datetime.datetime.fromtimestamp(WLM_JSON_DATA[worker]['startedAt']/1000).strftime("%H:%M:%S"),
			datetime.datetime.fromtimestamp(WLM_JSON_DATA[worker]['lastSeen']/1000).strftime("%d/%m/%y"),
			datetime.datetime.fromtimestamp(WLM_JSON_DATA[worker]['lastSeen']/1000).strftime("%H:%M:%S")
			)
		
		WLM_STRING_DATA.append(json_data_per_1_worker)

	return WLM_STRING_DATA	


def WLM_LOGGER(WLM_LOG_DATA,Environment):
	logger_name = "wlm_log_" + datetime.datetime.now().strftime("%Y%m%d") + ".log"
	log = open (logger_name,"a")
	log.write("========================= " + Environment + " =====================\n")
	log.write("=============== " + datetime.datetime.now().strftime("%x at %X") + " =====================\n")
	log.write("Nama_Worker\tStart_date\tStart_time\tLast_seen_date\tLast_seen_time\n")
	for worker_tuple in WLM_LOG_DATA :
		for worker_data in worker_tuple:
			log.write (worker_data + "\t")

		log.write("\n")

	log.write("\n")

	log.close




MANDOR("PROD")
MANDOR("PREPROD")
MANDOR("UAT")
MANDOR("LAB")
input ("\nEnter to close :")