#!/bin/bash
#source VAR
source /.IPS
if [ -z ${1} ] ; then
    echo
    etcdctl ls --sort ctrl/cfg/mg | cut -d '/' -f 5
    echo
    exit 1
fi

jobstart "$$"
trap "jobtrace '$$'" 0 1 2 3 6

mgenv="ctrl/cfg/mg/${1}"
username=$(etcdctl get $mgenv/config_system/mgmt_admin_name)
password=$(etcdctl get $mgenv/config_system/mgmt_admin_passwd)
mghost=$(etcdctl get $mgenv/config_system/hostname)
host=$(echo "$mghost" | cut -d '.' -f 1)          
ctrlip=$(curl -s ipecho.net/plain)
ctrlname="$SKEY"
baseurl=https://$mghost/web_api
curl_cmd="curl --silent --insecure -X POST"

SID=`${curl_cmd} -H "Content-Type: application/json" -d @- $baseurl/login <<. | awk -F\" '/sid/ {print $4}'
{
  "user":"$username" ,
  "password":"$password" ,
  "session-name":"$BUDDY $ipscmd add ctrl session $SKEY"
}
.`
# Login complete, add objects, rules and such here.
################################################################################################

sleep 5
msgbus "$ipscmd is session: $SID"

${curl_cmd} -H "Content-Type: application/json" -H "X-chkp-sid: $SID" -d @- $baseurl/add-group <<.
{
  "name" : "IPSControllers",
  "color" : "GREEN"
}
.

sleep 4

${curl_cmd} -H "Content-Type: application/json" -H "X-chkp-sid: $SID" -d "{}" $baseurl/publish
sleep 5

${curl_cmd} -H "Content-Type: application/json" -H "X-chkp-sid: $SID" -d @- $baseurl/add-host <<.
{
  "name" : "${ctrlname}",
  "ipv4-address" : "${ctrlip}",
  "set-if-exists" : true,
  "groups" : "IPSControllers"
}
.

sleep 5

${curl_cmd} -H "Content-Type: application/json" -H "X-chkp-sid: $SID" -d @- $baseurl/set-access-rule <<.
{
  "layer" : "Network",
  "name" : "Cleanup rule",
  "track" : "log"
}
.
 
sleep 5

${curl_cmd} -H "Content-Type: application/json" -H "X-chkp-sid: $SID" -d @- $baseurl/add-access-rule <<.
{
  "layer" : "Network",
  "position" : "top",
  "name" : "ssh Access",
  "source" : "IPSControllers",
  "service" : "ssh_version_2",
  "action" : "Accept",
  "track" : "none",
  "install-on" : "Policy Targets"
}
.


sleep 5

${curl_cmd} -H "Content-Type: application/json" -H "X-chkp-sid: $SID" -d @- $baseurl/add-access-section <<.
{
  "layer" : "Network",
  "position" : "top",
  "name" : "Kill em all"
}
.
 
################################################################################################
# Publish and get out of here
${curl_cmd} -H "Content-Type: application/json" -H "X-chkp-sid: $SID" -d "{}" $baseurl/publish
sleep 5

#Logout
${curl_cmd} -H "Content-Type: application/json" -H "X-chkp-sid: $SID" -d "{}" $baseurl/logout

msgbus "management first configuration setup done. Prep work done, ready for cloud demo. "

