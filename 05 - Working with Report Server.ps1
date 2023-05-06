#============================================================================
#	File:		05 - Working with Report Server.ps1
#
#	Summary:	This script shows some samples how to work with
#           PowerShell and Report Server
#
#	Date:		    2023-05-06
#
# Revisionen: yyyy-dd-mm
#                   - ...
#
#	Project:	  SQL Saturday New York City 2023
#
#	PowerShell Version: 5.1
#------------------------------------------------------------------------------
#	Written by
#       Frank Geisler, GDS Business Intelligence GmbH
#
# THIS CODE AND THE INFORMATION CONTAINED HEREIN ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND.
# NATURE, EXPRESS OR IMPLIED, INCLUDING,
# BUT NOT LIMITED TO FUNCTIONALITY OR FITNESS FOR A PARTICULAR
# PURPOSE. YOU USE THE CODE AT YOUR OWN RISK.
#============================================================================*/

#----------------------------------------------------------------------------
# 00. Variables
#----------------------------------------------------------------------------

# Download Test Reports 
$url = "https://github.com/Microsoft/tigertoolbox/raw/master/SQL-performance-dashboard-reports/SQL%20Server%20Performance%20Dashboard%20Reporting%20Solution.zip"
$output = "$env:USERPROFILE\Documents\performanceReportingDashboard.zip"
$unzipPath = "$env:USERPROFILE\Documents\performanceReportingDashboard"

# Create Folder
$ReportServerUri = "http://localhost/ReportServer"
$ReportFolderName = "MSSQLTips"

#----------------------------------------------------------------------------
# 01. Show all the commands
#----------------------------------------------------------------------------
Get-Command `
  -Module ReportingServicesTools

#----------------------------------------------------------------------------
# 02. Get some reports
#     Reports are from the tiger team on sql server performance
#     You can get them here: 
#----------------------------------------------------------------------------
Invoke-WebRequest `
    -Uri $url `
    -OutFile $output

Expand-Archive `
  -LiteralPath $output `
  -DestinationPath $unzipPath

#----------------------------------------------------------------------------
# 03. Upload Reports to Report Server
#----------------------------------------------------------------------------
New-RsFolder `
  -ReportServerUri $ReportServerUri `
  -Path / `
  -Name $ReportFolderName

Write-RsFolderContent `
  -ReportServerUri $ReportServerUri `
  -Path "$unzipPath\SQL Server Performance Dashboard" `
  -Destination "/$ReportFolderName" 

