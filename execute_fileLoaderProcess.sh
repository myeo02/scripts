#!/bin/bash
#set -x
TIMESTAMP=`date +%Y-%m-%d_%H:%M`
#LOG_DIR="/usr/apps/pisc_as/pisc/CAR/input/finance/logs"

#
# Display_Usage when user has supplied -h or --help
#
display_usage(){
	echo "Usage: This script takes in two arguments (Source System and environment)."
	echo -e " source system such as AGE, CAR_Finance, CAR_License, CAR_Product, and etc "
	echo -e " environment such as local, dev, test, perf, prod, and etc"
}


#
# Check for input parameters
#

if [[ "$#" == "--help" ]] || [[ "$#" == "-h" ]]
then
display_usage
return 0
elif [[ "$#" -ne 2 ]]
then
display_usage
return 1
elif [[ "$#" -eq 2 ]]
then
sourceSystem=$1
env=$2
echo "Source System argument "$sourceSystem" and environment argument" $env
propertyFile="inputs_"$sourceSystem"_"$env".properties"
	if [ ! -f  "$propertyFile" ] 
	then
	echo "File " $propertyFile " is not present."
	return 1;
	else
	source $propertyFile
	echo "execute fileLoaderScript output to log file "${LOG_DIR}/$TIMESTAMP.log
	source fileLoaderScript.sh $sourceSystem $env >> ${LOG_DIR}/$TIMESTAMP.log 
	fi
fi

if [ "$?" -eq 0 ]
then
echo "Program runs successfully exit with zero "
#exit 0
else
echo "Program errors out"
#exit 1
fi

#exit 0

#set +x
