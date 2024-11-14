#!/usr/bin/env bash

##### Created: November 30 2023 #########################################################################################################
# Author: Sean Ryan 
# Version: 1.0.1
# This script queries AWS Workspace service for worksapceid, username, and running status
# Command line tools needed: ddiff, jq *These command based apps can be installed via homebrew for mac, or any package manager for linux
##########################################################################################################################################

#Global Variables
TODAY=$(date +"%Y-%m-%d")
TODAY_PLUS=$(date +"%Y-%m-%d-%s")
AWS_ZONE=$(cat ~/.aws/config | grep -w region | awk '{print $3}')

#Pick a region in which to run your query against
select region0 in us-east-1 us-west-2 ap-southeast-1

do

    echo "The current region is set for $AWS_ZONE..." 
    echo "Selected character: $region0"
    aws configure set region $region0 
    echo "The region of $region0 has been set..."
    AWS_ZONE=${region0}    
	   
	break 	

done

#Report query begins
echo "Running ${AWS_ZONE} Report..."

## Query AWS for all Workspace status
aws workspaces describe-workspaces > workspaces_query.json

## Create list showing workspaceid, username, and running state
jq -r '[.Workspaces[] | {workspace: .WorkspaceId, username: .UserName, ComputerName: .ComputerName, runningmode: .WorkspaceProperties.RunningMode, State: .State}]' workspaces_query.json | xargs -n12 | sed 's/}, {//g' | sed 's/} ]//g' | sed '/^$/d' > workspaces_query_results.log

## Experimental Connection status (last known connection time) 
aws workspaces describe-workspaces-connection-status > workspaces_connection_query.json 

## Create a list showing workspaceid, connection state, and last known connection times
jq -r '[.WorkspacesConnectionStatus[] | {workspaceid: .WorkspaceId, connectionstatus: .ConnectionState, connectionstatechecktimestamp: .ConnectionStateCheckTimestamp, lastknownuserconnectiontimestamp: .LastKnownUserConnectionTimestamp}]' workspaces_connection_query.json | xargs -n 10 | sed 's/^....//' | sed '$d' > workspaces_connection_query_results.log

## merge both files together for final report 
paste -d, workspaces_query_results.log workspaces_connection_query_results.log | awk -F ',' '{print $1",",$2",",$3",",$5",",$6",",$7}' > workspace_query_${TODAY_PLUS}.csv

## extract last known user active date
cat workspaces_connection_query_results.log | awk -F ',' '{print $4}' | awk -F ':' '{print $2}' | sed 's/...$//' |  sed 's/n/2000-01-01/' > last_known_connection.log

## file format/output clean up
cat /dev/null > days_since_last_seen.log

## calculate days last seen/user active
DAYS_SINCE_LAST_SEEN=( $(cat last_known_connection.log) ) 

for str1 in "${DAYS_SINCE_LAST_SEEN[@]}"

do
 	ddiff ${TODAY} ${str1} >> days_since_last_seen.log 
done

## merge files and columns
paste -d "," workspace_query_${TODAY_PLUS}.csv days_since_last_seen.log > results_alpa.log

## print out neccessary columns
cat results_alpa.log | awk -F ',' '{print $1",",$2",",$3",",$4",",$6",", "dayssincelastseen: "$7}' > ${AWS_ZONE}_workspaces_production_report_${TODAY_PLUS}.csv

## Report status
echo "${AWS_ZONE} Report complete..."

## remove old files
rm -rf *.log
rm -rf workspace_query_*.csv
rm -rf *.json
