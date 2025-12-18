#!/usr/bin/env bash
###################################################################################################
# Author: Sean Ryan <nysean79@gmail.com>                                                          #
# Version: 1.0.0                                                                                  #
# Date: December 18th 2025                                                                        #
# This script generates a csr certificate to be submitted as a CSR request for an SSL certificate #
# Change the attribute of $domain to match your FQDN to be encrypted with SSL                     #
###################################################################################################

#Common Name of Certificate / hostname that requires SSL encryption
domain="subdomain.domain.com"

#Change to your company details
commonname=${domain}
country="US"
state="New York"
locality="New York"
organization="Domain Org"
organizationalunit="IT"
email="admin@domain.com"
rsa_encryption_level="4096"

#Password for certificate key file | No spaces are allowed in the password phrase
password="PUT YOUR PASSWORD HERE"

#Creation Status
echo "Generating key request for ${domain}..."

#Generate a private key via passphrase
openssl genrsa -passout pass:${password} -out ${domain}.key ${rsa_encryption_level}

#Remove passphrase from the key. Comment the line out to keep the passphrase
echo "Removing passphrase from key"
openssl rsa -in ${domain}.key -passin pass:${password} -out ${domain}_unencrypted.key

#Create the request
echo "Creating CSR"
openssl req -new -key ${domain}.key -out ${domain}.csr -passin pass:$password \
    -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"

echo "---------------------------"
echo "-----Below is your CSR-----"
echo "---------------------------"
echo
cat ${domain}.csr
