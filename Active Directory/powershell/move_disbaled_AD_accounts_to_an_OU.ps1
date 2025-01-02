##### Created: November 30 2023 #########################################################################################################
# Author: Sean Ryan 
# Version: 1.0.1
# This Powershell script will take all local Active Directory accounts which are disabled, and move them to a desired OU as needed defined 
# as "-TargetPath"
# This script can be ran directly on a domain controller.
##########################################################################################################################################
# Enable Powershell module needed to interact with Active Directory
Import-Module ActiveDirectory

# Create User account list
$DisabledUsers = Search-ADAccount -AccountDisabled | Select-Object -ExpandProperty SamAccountName

# Move each user added to '$DisabledUsers' variable to be evaluated by a foreach loop
foreach ($User in $DisabledUsers) {
  $UserDN = (Get-ADUser $User).DistinguishedName
  Move-ADObject -Identity $UserDN -TargetPath "OU=Disabled Users,DC=domain,DC=lan"
}
