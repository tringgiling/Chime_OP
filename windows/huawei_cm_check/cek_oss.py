#! python

import subprocess

Bali = []

def check_cm(region,ip,username,password):
	curl_syntax_maker = ("curl --list-only --user " + username + ":" + password + " ftp://" + ip + "//export/home/sysm/ftproot/TimerTask/CFGMML/")
	cm_check_to_ftp = subprocess.check_output(curl_syntax_maker,shell=True)
	cm_check_to_ftp_byte_to_string = cm_check_to_ftp.decode('utf-8')
	region.append(cm_check_to_ftp_byte_to_string)

check_cm(Bali,"10.212.82.4","ftptest","T3lk0ms3l#2")

print(Bali[0])
