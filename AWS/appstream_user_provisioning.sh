#!/usr/bin/env bash

## These sets of commands below are working examples used to administrate AWS Appstream services

## Create Local AWS App Stream Accounts
aws appstream create-user --user-name john.smith@example.com --first-name John --last-name Smith --authentication-type USERPOOL

## Add users to local stacks
aws appstream batch-associate-user-stack --user-stack-associations StackName=SAML_Test,UserName=john.smith@example.com,AuthenticationType=USERPOOL,SendEmailNotification=True

## Delete Local AWS App Stream Account
aws appstream delete-user john.smith@example.com --authentication-type USERPOOL
