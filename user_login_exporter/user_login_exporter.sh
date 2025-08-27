#!/bin/bash
TODAY=$(date +%Y%m%d)
CATALINA_EXPORT_FILE="catalina_user_login_export_$TODAY.log"

# get catalina export user login log
echo "get catalina user login from all TOMCAT Prod"
ssh cellwize@10.62.101.75 "grep -a \"logged into the system\|Server version number\" /opt/shares/tsel_prod_vio/services_logs/chime_studio_0*/catalina.out" 
>> $CATALINA_EXPORT_FILE
echo "done export user login info from catalina"
#ambil data user login sama tanggal dari catalina.out
#grep -a "logged into the system\|Server version number" /opt/tomcat/logs/chime_studio_01/catalina.out
#grep tanggal di awal line
#egrep -o "^[0-9]{1,2}\-...\-20[0-9]{1,2}" nama-file.txt

#loop line by line and then egrep the date
echo "Start parsing user login with date in readable format"
LOGIN_DATE=""
while IFS="" read -r p || [ -n "$p" ]; 
do
        LINE=$(printf '%s\n' "$p")  #print the line
        GREP_DATE=$(echo $LINE | egrep -o "[0-9]{1,2}\-...\-20[0-9]{1,2}")  #print the line and grep date
        GREP_DATE_STATUS=$?
        if [ $GREP_DATE_STATUS == 0  ]
        then
                LOGIN_DATE=$(printf '%s\n' "$p" | egrep -o "^[0-9]{1,2}\-...\-20[0-9]{1,2}")
                #echo $LOGIN_DATE
        else
                echo "$LOGIN_DATE%$LINE" | sed 's/%.*User /,/g' | sed 's/logged.*//g' | sed -E 's/\ {2,9}/ /g'
        fi

 done < $CATALINA_EXPORT_FILE
