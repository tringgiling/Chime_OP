for id in $(cat ID_suspend_CJ.txt); do
(echo "====="
echo "ID Task '$id' suspended"
echo 'curl -I -X POST "http://10.62.101.62:9090/wlm/tasks/"$id"/suspend" -H "accept: */*"'
curl -I -X POST "http://10.62.101.62:9090/wlm/tasks/$id/suspend" -H "accept: */*"
) >> iqbal.txt
done
