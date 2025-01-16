#!/usr/bin/env bash
##### February 28 2023 ######################################################################################
# Author: Sean Ryan <nysean79@gmail.com>
# Version: 1.0.0
# FAQ: The script references a list of emails to apply a license, and to archive a user
# based upon the Google SKU you use found here: developers.google.com/admin-skd/licensing/v1/hot-tos/products
#############################################################################################################

#### Format/Contents of google_email_list_test.csv ######################################
Format rules: no spaces, no trailing spaces, no blank lines, one email address per line
e.g. 

jsmith@example.com
rdavis@example.com
bross@example.com

# Global Variables 

TODAY_PLUS=$(date +"%Y-%m-%d-%s")
HOME_DIR=$(echo $HOME)
PRODCUT_SKU_ID=1010020020 

# Load GAM executable path/function

gam () {
	"${HOME_DIR}/bin/gam/gam" "$@"
}

# GAM Script logic

GAM_USER_EMAIL_LIST=( $(cat google_email_list_test.csv) )

for GAM_USER in "${GAM_USER_EMAIL_LIST[@]}" 

do
	gam user $GAM_USER add license $PRODUCT_SKU_ID ; gam update user $GAM_USER archived on  

done &>> gam_user_logging_changes_${TODAY_PLUS}.txt
