#!/bin/bash

# Define global vars
totalMemOID=".1.3.6.1.4.1.2021.4.5.0"
availMemOID=".1.3.6.1.4.1.2021.4.6.0"
bufferMemOID=".1.3.6.1.4.1.2021.4.14.0"
cachedMemOID=".1.3.6.1.4.1.2021.4.15.0"

# Define defaults
warningMem="20"
criticalMem="10"

while getopts a:p:s:w:c flag; do
	case "${flag}" in
		a) address=${OPTARG};;
		p) port=${OPTARG};;
		s) password=${OPTARG};;
		w) warning=${OPTARG};;
		c) critical=${OPTARG};;
	esac
done

# get snmp values
totalMem=$(snmpget -v 2c -c $password $address $totalMemOID 2>/dev/null|awk '{print $NF}')
availMem=$(snmpget -v 2c -c $password $address $availMemOID 2>/dev/null|awk '{print $NF}')
bufferMem=$(snmpget -v 2c -c $password $address $bufferMemOID 2>/dev/null|awk '{print $NF}')
cachedMem=$(snmpget -v 2c -c $password $address $cachedMemOID 2>/dev/null|awk '{print $NF}')

# math time
usedMem=$(echo "$totalMem-$availMem"|bc)
percentMem=$(echo "scale=4;($usedMem-$bufferMem-$cachedMem)/$totalMem"|bc)

echo $percentMem
