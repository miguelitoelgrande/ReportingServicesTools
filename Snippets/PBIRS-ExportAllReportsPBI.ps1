## Powershell script based on ReportingServicesTools
## Will backup/dump all Power BI Report Server reports to file system
## including subfolders, however without retaining permissions, connection credentials or refresh schedules.
## Author: Michael Mlivoncic , 2020
##
## How to run:
## Need to set executionpolicy for this:
## Invocation:  powershell  -executionpolicy bypass  -File PBIRS-ExportAllReportsPBI.ps1 
##

$PBIRS = 'mypbirs.reportserver.com'
$reportServerURI = "https://$($PBIRS)/ReportServer"
$reportPortalURI = "https://$($PBIRS)/reports"

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

####################################################
## Fix: "/Users Folders" sometimes causes trouble due to special privileges
## Have a look at:
## https://github.com/miguelitoelgrande/ReportingServicesTools/blob/master/ReportingServicesTools/Functions/CatalogItems/Rest/Out-RsRestFolderContent.ps1
## for my little try-catch block as quick fix..
###############################################


#create a timestamped folder, format similar to 2011-Mar-28-0850PM
$folderName = Get-Date -format "yyyyMMdd_HHmm";

## Server backup - Folder MUST exist!!!
$fullFolderName = "C:\Temp\PBIRSbackup_$($PBIRS)_" + $folderName;
[System.IO.Directory]::CreateDirectory($fullFolderName) | out-null
Out-RsRestFolderContent -Destination $fullFolderName -RsFolder "/" -Recurse -ReportPortalUri $reportPortalURI

## Howto reimport to a server (however only one folder at a time - not including schedules, permissions, etc.):
## Write-RsRestFolderContent -ReportPortalUri $reportPortalURI -Path 'c:\temp\SomePBIfolderBackup' -RsFolder '/Import' 
## Use Option   -Overwrite  to overwrite...


## Alternative? Unfortunately only for paginated reports, not for PowerBIReports:
##Out-RsFolderContent -ReportServerUri $reportServerURI  -RsFolder / -Recurse -Destination  $fullFolderName


