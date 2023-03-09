#! python

import subprocess
import re

def check_cm_with_winscp(region):
	configuration_txt_file = region + ".txt"
	print ("Sedang berkunjung ke OSS : " + region)
	winscp_oss_output = subprocess.check_output([r'connect_to_oss_using_winscp.bat', configuration_txt_file]).decode('utf-8')
	
	#kalau mau return string
	return winscp_oss_output



North_Sumatra = check_cm_with_winscp("North_Sumatra")
Central_Sumatra = check_cm_with_winscp("Central_Sumatra")
South_Sumatra = check_cm_with_winscp("South_Sumatra")
Jabodetabek_18 = check_cm_with_winscp("Jabodetabek_18")
Jabodetabek_23 = check_cm_with_winscp("Jabodetabek_23")
Jabodetabek_26 = check_cm_with_winscp("Jabodetabek_26")
West_Java = check_cm_with_winscp("West_Java")


### Test Case, Tested
# print ("\nNorth Sumatra" + North_Sumatra)
# print ("\nCentral Sumatra" + Central_Sumatra)
# print ("\nSouth_Sumatra" + South_Sumatra)
# print ("\nJabodetabek_18" + Jabodetabek_18)
# print ("\nJabodetabek_23" + Jabodetabek_23)
# print ("\nJabodetabek_26" + Jabodetabek_26)
# print ("\nWest_Java" + West_Java)

### Contoh Regex
cm_file = max(re.findall ("MBSC_TTCAmirHamzah1" + "_",North_Sumatra))
time_stamp = max(re.findall(r'(?<=' + re.escape("MBSC_TTCAmirHamzah1") + '_)[^ ][0-9]{1,8}',North_Sumatra))
print (cm_file)
print (time_stamp)



#for x in winscp.splitlines():
#	print (x)
# log = open("iqbal.txt","a")
# log.write (str(winscp.decode('utf-8')))
# log.close 