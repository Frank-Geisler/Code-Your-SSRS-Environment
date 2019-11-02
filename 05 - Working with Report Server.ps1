#============================================================================
#	Datei:		05 - Working with Report Server.ps1
#
#	Summary:	This script shows some samples how to work with
#               PowerShell and Report Server
#
#	Datum:		2019-11-02
#
#   Revisionen: yyyy-dd-mm
#                   - ...
#
#	Projekt:	SQL Saturday Oregon 2019
#
#	PowerShell Version: 5.1
#------------------------------------------------------------------------------
#	Geschrieben von 
#       Frank Geisler, GDS Business Intelligence GmbH
#
#   DIESER CODE UND DIE ENTHALTENEN INFORMATIONEN WERDEN OHNE GEWÄHR JEGLICHER
#   ART ZUR VERFÜGUNG GESTELLT, WEDER AUSDRÜCKLICH NOCH IMPLIZIT, EINSCHLIESSLICH,
#   ABER NICHT BESCHRÄNKT AUF FUNKTIONALITÄT ODER EIGNUNG FÜR EINEN BESTIMMTEN
#   ZWECK. SIE VERWENDEN DEN CODE AUF EIGENE GEFAHR.
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