#!/bin/bash

# Define global vars
totalOID=".1.3.6.1.4.1.2021.9.1.6.1"
usedOID=".1.3.6.1.4.1.2021.9.1.8.1"
percentOID=".1.3.6.1.4.1.2021.9.1.9.1"
unknownErrorMsg="Error unknown: Unable to communicate with SNMP"

# Define defaults
percentWarning="80"
percentCritical="90"

while getopts a:p:s:w:c flag; do
	case "${flag}" in
		a) address=${OPTARG};;
		p) port=${OPTARG};;
		s) password=${OPTARG};;
		w) warning=${OPTARG};;
		c) critical=${OPTARG};;
	esac
done

# Pull data
totalSpace=$(snmpget -v 2c -c $password $address $totalOID 2>/dev/null|awk '{print $NF}')
if [ $? -ne 0 ]; then
	echo $unknownErrorMsg
	exit 3
fi
usedSpace=$(snmpget -v 2c -c $password $address $usedOID 2>/dev/null|awk '{print $NF}')
if [ $? -ne 0 ]; then
	echo $unknownErrorMsg
	exit 3
fi
percentSpace=$(snmpget -v 2c -c $password $address $percentOID 2>/dev/null|awk '{print $NF}')
if [ $? -ne 0 ]; then
	echo $unknownErrorMsg
	exit 3
fi

# Check if critical is reached
if [ $percentSpace -ge $percentCritical ]; then
	echo "Critical: $percentSpace% disk space used ($usedSpace KB / $totalSpace KB)"
	exit 2
fi

# Check if warning is reached
if [ $percentSpace -ge $percentWarning ]; then
	echo "Warning: $percentSpace% disk space used ($usedSpace KB / $totalSpace KB)"
	exit 1
fi

# if the script makes it to this point, everything is ok
echo "OK - $percentSpace% disk space used ($usedSpace KB / $totalSpace KB)"
exit 0
