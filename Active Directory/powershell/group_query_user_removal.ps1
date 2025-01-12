
#### April 28 2022 #############################################################################################################################
# Author: Sean Ryan 
# Version: 1.0.0
# FAQ: The script works by taking a list of users and for each user in the list it will query the defined AD groups for membership confirmation
################################################################################################################################################

## backup membership of group adding a total member count

  Get-ADGroupMember -Identity view_only_dev | Select-Object name > C:\scripts\view_only_dev_membership.txt
  Get-ADGroupMember -Identity view_only_dev | Select-Object name | Measure-Object >> C:\scripts\view_only_dev_membership.txt

## clear user variable before running
## load list of users from a text file into a variable 
## note this uses the pre-windows 2000 naming convention

   $UsersFile = $null
   $UsersFile = Get-Content "C:\scripts\termed-users.txt"

# Specify target group where the users will be removed from
# You can add the distinguishedName of the group. For example: CN=Pilot,OU=Groups,OU=Company,DC=exoip,DC=local

# clear AD group variables before running
    $Group = $null
    $Group = "view_only_dev"
    
foreach ($User in $UsersFile) {
 
  # Retrieve AD user group membership
    $ExistingGroups = Get-ADPrincipalGroupMembership $User | Select-Object samaccountname > C:\scripts\group-membership.txt  
    $GroupVariable = Get-Content "C:\scripts\Desktop\group-membership.txt"

# If user is a member of the defined AD group, then remove from defined group, and confirm with a pop-up box to proceed to remove said user
if ($GroupVariable -match $Group) {
  
    Write-Host "The user $User is a Member of view_only_dev" -ForeGroundColor Blue
    Remove-ADGroupMember -Identity $Group -Members $User -Confirm:$false -WhatIf
    Write-Host "The user $User has also Removed from view_only_dev" -ForeGroundColor Green
    Write-Output "$User" >> C:\users\sryan\desktop\view_only_dev_successfully-removed.log

    }

# Confirmation of the users not existing in the said groups

else { 
    
    Write-Host "The user $User is not a member of the view_only_dev"  -ForegroundColor Yellow
    Write-Output "$User" >> C:\scripts\view_only_dev_error.log
    
    }  
}
   
