#!/bin/bash

# Define global vars
totalOID=".1.3.6.1.4.1.2021.9.1.6.1"
usedOID=".1.3.6.1.4.1.2021.9.1.8.1"
percentOID=".1.3.6.1.4.1.2021.9.1.9.1"
unknownErrorMsg="Error unknown: Unable to communicate with SNMP"

# Define defaults
percentWarning="80"
percentCritical="90"

# predefine arguments
address=""
password=""

while getopts a:p:h flag; do
	case "${flag}" in
		a) address=${OPTARG};;
		p) password=${OPTARG};;
		h) usage;;
		*) usage
	esac
done

function usage() {
	echo -e "\nUsed to check the cpu load on a pfSense device"
	echo -e "\nUsage:\n\n $(basename "$0") [options]"
	echo -e "  -a <address>\tThe IP address of the pfSense device"
	echo -e "  -p <password>\tThe password (community string)"
	echo -e "\nExample:\n"
	echo -e "$0 -a 192.168.1.1 -p public\n"
	exit 0
}

if [ -z "$address" ] || [ -z "$password" ] || [ "$showHelp" == "true" ]; then
	usage
fi

# Pull data
totalSpace=$(snmpget -v 2c -c "$password" "$address" "$totalOID" 2>/dev/null|awk '{print $NF}')
if [ "$?" -ne 0 ]; then
	echo "$unknownErrorMsg"
	exit 3
fi
usedSpace=$(snmpget -v 2c -c "$password" "$address" "$usedOID" 2>/dev/null|awk '{print $NF}')
if [ "$?" -ne 0 ]; then
	echo "$unknownErrorMsg"
	exit 3
fi
percentSpace=$(snmpget -v 2c -c "$password" "$address" "$percentOID" 2>/dev/null|awk '{print $NF}')
if [ "$?" -ne 0 ]; then
	echo "$unknownErrorMsg"
	exit 3
fi

# Check if critical is reached
if [ "$percentSpace" -ge "$percentCritical" ]; then
	echo "Critical: $percentSpace% disk space used ($usedSpace KB / $totalSpace KB)"
	exit 2
fi

# Check if warning is reached
if [ "$percentSpace" -ge "$percentWarning" ]; then
	echo "Warning: $percentSpace% disk space used ($usedSpace KB / $totalSpace KB)"
	exit 1
fi

# if the script makes it to this point, everything is ok
echo "OK - $percentSpace% disk space used ($usedSpace KB / $totalSpace KB)"
exit 0
