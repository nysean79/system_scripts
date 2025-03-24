#!/usr/bin/env bash
##### August 31 2023 ####################################################################
# Author: Sean Ryan <nysean79@gmail.com>
# Version: 1.0.0
# FAQ: The script references a list of gsuite users via email to delete 
#########################################################################################

#### Format/Contents of google_email_list_test.csv ######################################
#Format rules: no spaces, no trailing spaces, no blank lines, one email address per line
#e.g. 

## CSV Email list File format Header requirement [Remove Comments below]

#Email,
#john.smith@example.com
#bob.roberts@example.com
#gary.drake@example.com

## Runtime rules

# 1. Run this file in the same directory as the csv email list file e.g. 'delete-users-list.csv'

# 2. Rename the csv file to match  'delete-users-list.csv' reference with your csv file in the same running directory

#### Global Variables ###################################################################

TODAY_PLUS=$(date +"%Y-%m-%d-%s")
USER_EMAIL_LIST='delete-users-list.csv'

### Load GAM executable path/function ###############

gam () {
	"~/bin/gam/gam" "$@"
}

####### 1. Script Logic  ###################

gam csv ${USER_EMAIL_LIST} gam delete user "~Email" &>> gam_user_logging_changes_${TODAY_PLUS}.txt
