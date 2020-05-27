## Powershell script based on ReportingServicesTools
## Will bulk modify Power BI Report Server permissions on reports and folders.
## e.g. migrating users from one domain to another.
## Author: Michael Mlivoncic , 2020
##
## How to run:
## Need to set executionpolicy for this:
## Invocation:  powershell  -executionpolicy bypass  -File PBIRS-BulkChangePermissions.ps1 
##

####################################################
## !!! Warning: Set server wisely. This script modifies the content!
## No way to revert.
####################################################
$reportServerURI = 'https://myserverurl/reportserver'

####################################################
## !!! You might need to run this first time...
####################################################
## Install-Module -Name InstallModuleFromGitHub  -Scope CurrentUser
## Update: Using my version as it contains a fix.
# $dest = $env:USERPROFILE + "\My Documents\WindowsPowerShell\Modules"
# Install-ModuleFromGitHub -GitHubRepo miguelitoelgrande/ReportingServicesTools -DestinationPath $dest
#################################################### 

#Import-Module ReportingServicesTools -Global -Function "*"
## Too much information :-)
$VerbosePreference = "Continue"

## get all User and Group Permissions on Folders (and subfolders)
$roleObjects = Get-RsCatalogItemRole -path '/' -ReportServerUri $reportServerURI -Recurse 

## Future extension: Export or import to/from file
## $roleObjects | Export-Clixml ./Reports.roles.xml
## $roleObjects = Import-Clixml ./Reports.roles.xml

foreach ($roleObj in $roleObjects) {
  #$roleObj.Roles | ForEach-Object {Write-Host ($($_.Name) ) }      
  
  $inherited = if ( $roleObj.ParentSecurity ) { "INHERITED"} else { "" }
   
  Write-Host "Object '$($roleObj.Path)'  $($roleObj.Identity) $inherited"   
  if ($roleObj.Identity.StartsWith("OLDDOMAIN\") -And -Not $roleObj.ParentSecurity) {   
      ## TODO: find a way to test if account exists in target domain....
      $oldIdent = $roleObj.Identity
	  $newIdent = $roleObj.Identity.Replace("OLDDOMAIN\","NEWDOMAIN\")
      Write-Host "Modding Identity '$($oldIdent)'->'$($newIdent)'"  
	  $roles = $roleObj.Roles

	  try {
		 foreach ($role in $roles) {
	        Write-Host "'$($roleObj.Path)'  '$($oldIdent)'->'$($newIdent)'  role='$($role.Name)'"  		 
		    Grant-RsCatalogItemRole -ReportServerUri $reportServerURI -Identity $newIdent -RoleName $role.Name -Path '/'		 
	     }

		  try {
				Revoke-RsCatalogItemAccess -ReportServerUri $reportServerURI -Identity $oldIdent -Path '/'
		  } catch {
				Write-Verbose "Error revoking permissions from Identity: '$($oldIdent)' on '$($reportpath)' failed"   
		  }
			 
		 
	  }
	  catch {		
            Write-Verbose "'$($roleObj.Path)' Error Identity '$($oldIdent)'->'$($newIdent)' role='$($role.Name)'"  			
	  }	
	  
  }
}


## sample output of "Get-RsCatalogItemRole":
# Identity       : BUILTIN\Administrators
# Path           : /Folder/Report
# TypeName       : Unknown
# Roles          : {Content Manager}
# ParentSecurity : False






