#!/bin/bash

# Define global vars
oneMinOID=".1.3.6.1.4.1.2021.10.1.3.1"
fiveMinOID=".1.3.6.1.4.1.2021.10.1.3.2"
fifteenMinOID=".1.3.6.1.4.1.2021.10.1.3.3"
unknownErrorMsg="Error unknown: Unable to communicate with SNMP"

# Define warning defaults
oneMinWarning="1.5"
fiveMinWarning="1.3"
fifteenMinWarning="1.1"

# Define critical defaults
oneMinCritical="1.7"
fiveMinCritical="1.5"
fifteenMinCritical="1.3"

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

# Check 1 minute load average
oneMinLoad=$(snmpget -v 2c -c "$password" "$address" "$oneMinOID" 2>/dev/null)
if [ "$?" -ne 0 ]; then
	echo "$unknownErrorMsg"
	exit 3
else
	oneMinLoad=$(echo "$oneMinLoad"|awk -F'"' '{print $2}')
	omlConv=$(echo "($oneMinLoad*100)/1"|bc 2>/dev/null)
	omlWarningConv=$(echo "($oneMinWarning*100)/1"|bc 2>/dev/null)
	omlCriticalConv=$(echo "($oneMinCritical*100)/1"|bc 2>/dev/null)
fi

# Check 5 minute load average
fiveMinLoad=$(snmpget -v 2c -c "$password" "$address" "$fiveMinOID" 2>/dev/null)
if [ "$?" -ne 0 ]; then
	echo "$unknownErrorMsg"
	exit 3
else
	fiveMinLoad=$(echo "$fiveMinLoad"|awk -F'"' '{print $2}')
	fmlConv=$(echo "($fiveMinLoad*100)/1"|bc 2>/dev/null)
	fmlWarningConv=$(echo "($fiveMinWarning*100)/1"|bc 2>/dev/null)
	fmlCriticalConv=$(echo "($fiveMinCritical*100)/1"|bc 2>/dev/null)
fi

# Check 15 minute load average
fifteenMinLoad=$(snmpget -v 2c -c "$password" "$address" "$fifteenMinOID" 2>/dev/null)
if [ $? -ne 0 ]; then
	echo "$unknownErrorMsg"
	exit 3
else
	fifteenMinLoad=$(echo "$fifteenMinLoad"|awk -F'"' '{print $2}')
	ftmlConv=$(echo "($fifteenMinLoad*100)/1"|bc 2>/dev/null)
	ftmlWarningConv=$(echo "($fifteenMinWarning*100)/1"|bc 2>/dev/null)
	ftmlCriticalConv=$(echo "($fifteenMinCritical*100)/1"|bc 2>/dev/null)
fi

# Check if critical is reached
if [ "$omlConv" -ge "$omlCriticalConv" ] || [ "$fmlConv" -ge "$fmlCriticalConv" ] || [ "$ftmlConv" -ge "$ftmlCriticalConv" ]; then
	echo "Critical: load average: $oneMinLoad, $fiveMinLoad, $fifteenMinLoad"
	exit 2
fi

# Check if warning is reached
if [ "$omlConv" -ge "$omlWarningConv" ] || [ "$fmlConv" -ge "$fmlWarningConv" ] || [ "$ftmlConv" -ge "$ftmlWarningConv" ]; then
	echo "Warning: load average: $oneMinLoad, $fiveMinLoad, $fifteenMinLoad"
	exit 1
fi

# if the script makes it to this point, everything is ok
echo "OK - load average: $oneMinLoad, $fiveMinLoad, $fifteenMinLoad"
exit 0
