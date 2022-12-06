#! python

import subprocess

#initial state
North_Sumatra = []
Central_Sumatra = []
South_Sumatra = []
Jabodetabek_18 = []
Jabodetabek_23 = []
Jabodetabek_26 = []
West_Java = []


def check_cm(region,ip,username,password):
	curl_syntax_maker = ("curl --list-only --user " + username + ":" + password + " ftp://" + ip + "//export/home/sysm/ftproot/TimerTask/CFGMML/")
	cm_check_to_ftp = subprocess.check_output(curl_syntax_maker,shell=True)
	cm_check_to_ftp_byte_to_string = str(cm_check_to_ftp.decode('utf-8'))
	cm_listed = cm_check_to_ftp_byte_to_string.replace("\r\n"," ").split() # ganti new line jadi whitespace, trus create list dan di seperate oleh whitespace
	region.extend(cm_listed)

#check_cm(North_Sumatra,"10.212.83.83","ftptest","T3lk0ms3l#2")
check_cm(Central_Sumatra,"10.212.83.57","ftptest","T3lk0ms3l#2")
check_cm(South_Sumatra,"10.212.83.5","ftpuser","Changeme_123")
check_cm(Jabodetabek_18,"10.168.194.5","ftptest","T3lk0ms3l#2")
check_cm(Jabodetabek_23,"10.168.194.48","ftptest","T3lk0ms3l#2")
check_cm(Jabodetabek_26,"10.168.194.100","ftptest","T3lk0ms3l#2")
check_cm(West_Java,"10.168.197.5","ftptest","T3lk0ms3l#2")

print(North_Sumatra)
print(Central_Sumatra)
print(South_Sumatra)
print(Jabodetabek_18)
print(Jabodetabek_23)
print(Jabodetabek_26)
print(West_Java)
