#!/usr/bin/env bash
##########################################################
# Author: Sean Ryan  <nysean79@gmail.com>                #
# Version: 1.0.0                                         #
# Date: December 18th 2025                               #
# FAQ: This script generates a home grown SSL certificate#
##########################################################

#Common Name of Cerficiate / hostname that requires SSL encryption
domain="domain.com"

#Certificate Attributes
commonname=${domain}
country="US"
state="New York"
locality="New York"
organization="Domain Org"
organizationalunit="IT"
email="it@domain.com"
rsa_encryption_level="4096"
cert_lifespan_days="3650"
IP="10.0.0.1"

openssl req -x509 -newkey rsa:${rsa_encryption_level} -sha256 -days ${cert_lifespan_days} \
 -nodes -keyout ${domain}.key -out ${domain}.crt \
 -subj "/C=${country}/ST=${state}/L=${locality}/O=${organization}/OU=${organizationalunit}/CN=${commonname}/emailAddress=${email}" \
 -addext "subjectAltName=DNS:${domain},DNS:*.${domain},IP:${IP}"

echo "Generating key request for ${domain}"

echo
echo "---------------------------"
echo "-----Below is your Key-----"
echo "---------------------------"
echo
cat ${domain}.key

echo
echo "--------------------------------"
echo "-----Verified Cert Attributes---"
echo "--------------------------------"
echo

openssl x509 -in ${domain}.crt -text
