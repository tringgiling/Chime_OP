for item in $(cat mini_site_list.txt); do
get_cell_info=$(curl -X GET "http://10.62.101.62:9091/naas/v1/cells?fields=ossId%2CuserLabel%2CRAN&includeExtensions=true&includeInsightsData=true&includeLabelsData=true&includePhysicalData=true&links=false&name=$item&per_page=200" -H "accept: application/json")
echo $get_cell_info | grep -oP 'ossId":"27"'
if [ $? -eq 0 ]
then (echo "$item, contain Ran 11") >> "daftar_mengandung_ran11.csv"

else  (echo $get_cell_info | grep -oP '("ossId":"24","userLabel":")[^}]*') >> "daftar_murni_ran8.csv"

fi


done

