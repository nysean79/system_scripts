#!/usr/bin/env bash
######################################################################################################################################
# Author: Sean Ryan  <nysean79@gmail.com>                                                                                            #
# Version: 1.0.0                                                                                                                     #
# Date: December 18th 2025                                                                                                           #
# FAQ: This script checks the key files generated during CSR creation against the certificates which are issued from a cert provider #
######################################################################################################################################

# Generated during Certificate Creation
KEY_FILE="domain.com.key"

# Single or Full Chain certificate file(s) can be used
CERT="full_chain_domain.com.crt"

# 2.) Verify that the cert and key match - Success here is that both MD5s are identical e.g. MD5(stdin)= edd5e0110bd8606ab1006fb3e28fkt45

openssl x509 -noout -modulus -in ${CERT} | openssl md5 > /tmp/certificate_output.txt
openssl rsa -noout -modulus -in ${KEY_FILE} | openssl md5 > /tmp/key_output.txt

# Compare the varialbles of ${KEY_FILE} and ${CERT} for a match
KEY_FILE_OUTPUT=$(cat /tmp/key_output.txt)
CERT_FILE_OUTPUT=$(cat /tmp/certificate_output.txt)

# 3. Verify the RSA key - Success here is OpenSSL returning "RSA key ok"
openssl rsa -check -noout -in ${KEY_FILE}

# compare the CERT and KEY_FILE variables for a match

if [[ ${KEY_FILE_OUTPUT} = ${CERT_FILE_OUTPUT} ]] ; then 
    echo "The certificate and key do match!" 

    echo "Key file md5:         ${KEY_FILE_OUTPUT}"
    echo "Certificate file md5: ${CERT_FILE_OUTPUT}"
else 
    echo "The certificate and key do not match" 

    echo "Key filke md5:        ${KEY_FILE_OUTPUT}"
    echo "Certificate file md5: ${CERT_FILE_OUTPUT}" 
fi                                    
