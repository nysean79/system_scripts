#!/usr/bin/env bash

##### Created: November 30 2023 #########################################################################################################
# Author: Sean Ryan 
# Version: 1.0.1
# FAQ: This AWS AppsStream script creates local user accounts, assigns the users an image/stack, and user pool.
##########################################################################################################################################

## These sets of commands below are working examples used to administrate AWS Appstream services

## Create Local AWS App Stream Accounts
aws appstream create-user --user-name john.smith@example.com --first-name John --last-name Smith --authentication-type USERPOOL

## Add users to local stacks
aws appstream batch-associate-user-stack --user-stack-associations StackName=SAML_Test,UserName=john.smith@example.com,AuthenticationType=USERPOOL,SendEmailNotification=True

## Delete Local AWS App Stream Account
aws appstream delete-user john.smith@example.com --authentication-type USERPOOL
