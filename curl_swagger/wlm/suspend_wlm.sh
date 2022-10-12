for id in $(cat wlm_suspend_gel_2.txt); do
(echo "====="
echo "Mensuspend ID Task '$id'"
echo 'curl -I -X POST "http://10.62.101.62:9090/wlm/tasks/'$id'/suspend" -H "accept: */*"'
echo "Response : "
curl -I -X POST "http://10.62.101.62:9090/wlm/tasks/$id/suspend" -H "accept: */*"
) >> iqbal.log
done
