#!/usr/bin/env bash
##### November 22 2023 ####################################################################
# Author: Sean Ryan <nysean79@gmail.com>
# Version: 1.0.0
# FAQ: The script shows the current owner of the google document per the document ID found 
# in the Google Drive Shared File URL
##########################################################################################

# load list of Google Document IDS: 
DOCID_LIST=( $(cat doc-list.txt) )

# For every line which has a document ID listed within doc-list.txt, run the command below inserting the docuemnt ID on the end
# of each command
for DOCID in "${DOCID_LIST[@]}" 

do

  # direct executable path of gam 
  /Users/jsmith/bin/gam7/gam  print ownership ${DOCID}

done >> DOC_ID_LOGGING.txt
