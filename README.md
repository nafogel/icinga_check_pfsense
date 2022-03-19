# icinga_check_pfsense
Custom pfSense monitoring checks for Icinga, an open source network monitoring tool based on Nagios.

## Details
Use these custom checks to monitor pfSense devices using Icinga.

## Setup
Simply add the `check_pfsense_*` scripts to the plugins directory for your Icinga installation, usually located in `/usr/lib/nagios/plugins/`.

## Usage
Each script accepts two arguments, `-a` and `-p`, which should be the IP address and password for the pfSense device you wish to monitor.
Additionally, each script contains several global variables at the top, representing the SNMP OIDs used to pull the relevant data.
