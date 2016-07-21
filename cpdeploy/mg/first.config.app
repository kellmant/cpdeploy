#!/bin/bash
source VAR
baseurl=https://$host/web_api
curl_cmd="curl --silent --insecure -X POST"

SID=`${curl_cmd} -H "Content-Type: application/json" -d @- $baseurl/login <<. | awk -F\" '/sid/ {print $4}'
{
  "user":"$username" ,
  "password":"$password" ,
  "session-name":"init_prep"
}
.`
# Login complete, add objects, rules and such here.
################################################################################################

sleep 5

${curl_cmd} -H "Content-Type: application/json" -H "X-chkp-sid: $SID" -d @- $baseurl/add-host <<.
{
  "name" : "$admin_host",
  "ip-address" : "$admin_ip"
}
.

sleep 5

${curl_cmd} -H "Content-Type: application/json" -H "X-chkp-sid: $SID" -d @- $baseurl/set-access-rule <<.
{
  "layer" : "Network",
  "name" : "Cleanup rule",
  "track" : "Full Log"
}
.
 
sleep 5

${curl_cmd} -H "Content-Type: application/json" -H "X-chkp-sid: $SID" -d @- $baseurl/add-access-rule <<.
{
  "layer" : "Network",
  "position" : "top",
  "name" : "ssh Access",
  "source" : "$admin_host",
  "service" : "ssh_version_2",
  "action" : "Accept",
  "track" : "Full Log",
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

echo " . . . management first configuration setup done. Prep work done, ready for cloud demo. "

