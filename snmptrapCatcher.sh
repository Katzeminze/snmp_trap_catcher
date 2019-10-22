#!/bin/sh

#EXAMPLE__________________________________________
#snmptrap -v 2c -c public localhost '' 1.3.6.1.4.1.8072.2.3.0.1 1.3.6.1.4.1.8072.2.3.2.1 i 123456


#"ls -la /bin/sh" command helps to check whether it is bash or dash. 
#In case of bash, the function definition should be "function sendToServer {"


# function in python
sendToServer() {  
host_id="$host" ip_id="$ip" val_id="$vars" python3 - <<END

import sys
import os
import re
import requests

host_name = str(os.environ['host_id'])
ip_address = str(os.environ['ip_id'])
p3 = str(os.environ['val_id'])

# Data to be processed
#str = "DISMAN-EVENT-MIB::sysUpTimeInstance = 1:6:27:46.58, SNMPv2-MIB::snmpTrapOID.0 = NET-SNMP-EXAMPLES-MIB::netSnmpExampleHeartbeatNotification, NET-SNMP-EXAMPLES-MIB::netSnmpExampleHeartbeatRate = 18"
severity_array = ["Emergency","Alert","Critical","Error","Warning","Notification","Informational","Debug"]

# Additional details
signL='{'
signR='}'
ExampleOfSeverity="Notification"

# Splitting trap string
p3_1,p3_2 = p3.split(" ",1)
naN, misc = p3_2.split("= ",1)
upTime, tmp = misc.split(", ", 1)
Nan, trap_detail = tmp.split("= ",1)
severity, trapString, trapValue = re.split(", |= ",trap_detail)
Nul, value_name = re.split("::",trapString)
Nul, trap_type = re.split("::",severity)

# Obtain severity status from trap string
match = next((x for x in severity_array if x in severity), False)
#if any(x in str for x in wordd):
print(match)#if str.find(wordd) != (-1):
lange = len(match)
number = severity.find(match)
severity_val_from_trap = severity[number:number+lange]


if not trapValue:
	value_of_trap_to_send = 0
else:
	value_of_trap_to_send = int(trapValue)

#print(number, severity_val_from_trap, value_of_trap_to_send, value_name)


# loging to the IOTServer
url = "https://iottest.mti.tul.cz/IOTServer/v2/users/login"

payload = "{\n    \"email\": \"test@email\",\n    \"password\": \"HESLO\"\n}"
headers = {
    'Content-Type': "application/json",
    'cache-control': "no-cache",
    'Postman-Token': "457c2f25-740a-45b5-8070-c13d4a1534ce"
    }
response = requests.request("POST", url, data=payload, headers=headers)


#send trap data to IOTServer
url = "https://iottest.mti.tul.cz/IOTServer/v2/data_universal_events/"

payload = "{0}\n    \"timestamp\": 7673311,\n    \"milliseconds\": 999,\n    \"duration\": 1,\n    \"device_id\": 1,\n    \"phase\": \" \",\n    \"type\": \"{1}\",\n    \"severity\": \"{2}\",\n    \"note\": \"Snmptrap\",\n    \"value_1\": {3},\n    \"value_1_name\": \"{4}\",\n    \"value_1_unit\": \"\",\n    \"value_2\": -1,\n    \"value_2_name\": \"none\",\n    \"value_2_unit\": \"none\"\n {5}".format(signL,trap_type[14:len(trap_type)-lange],severity_val_from_trap,value_of_trap_to_send,value_name[14:len(value_name)-1],signR)
headers = {
    'Content-Type': "application/json",
    'Authorization': "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1NzA0Nzc2NDAsImlhdCI6MTU3MDQ3NTg0MCwic3ViIjoyOX0.f6aOUQbqQu7tQMG1klvK5ONxdQi77m8HbuFJA65DUJc",
    'cache-control': "no-cache",
    'Postman-Token': "38deef1f-b99e-429e-ab37-35c6f744fe3a"
    }
response = requests.request("POST", url, data=payload, headers=headers)


# writing to the file to check the response
f = open('/home/kate/python_scripts/ex', 'w') 
f.write(host_name + "\n" + ip_address + "\n" + p3 + "\n" + p3_1 + "\n" + upTime + "\n" + severity + "\n" + trapString + "\n" + trapValue + "\n" + response.text + "\n" + payload)
f.write(payload)
f.close() 

END
}


# Bash script 
read host
read ip
vars=
 
while read oid val
do
  if [ "$vars" = "" ]
  then
    vars="$oid = $val"
  else
    vars="$vars, $oid = $val"
  fi
done

sendToServer "$host" "$ip" "$vars"



