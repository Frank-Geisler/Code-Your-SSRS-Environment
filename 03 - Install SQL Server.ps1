#============================================================================
#	File:		04 - Setup SQL Server.ps1
#
#	Summary:	This script brings the sql server into the domain
#
#	Date:	    2023-05-06
#
# Revisions: yyyy-dd-mm
#                   - ...
#
#	Project:	SQL Saturday New York City 2023
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
$computer_name = 'sql'
$domain_name = 'ssrs.net'
$admin_user = 'SSRS\ssrsadmin'

# ReportServer
$database_servername = 'localhost'
$report_servername = 'ReportServer'
$report_serverinstance = 'SSRS'
$sqlserver_version = 'SQLServer2017'

# Encryption Key
$encryptionkey_pass = 'Pa$$w0rd1'
$encryptionkey_path = $env:USERPROFILE+'\Documents\ssrs_key.snk'

#--------------------------------------------------------------------------
# 01. - Client aktualisieren
# -------------------------------------------------------------------------
Set-ExecutionPolicy `
  -ExecutionPolicy Unrestricted `
  -Force

Install-Module PSWindowsUpdate `
    -Force

Install-WindowsUpdate `
   -AcceptAll `
   -AutoReboot   

#--------------------------------------------------------------------------
# 02. - Computer zur Domäne hinzufügen
# -------------------------------------------------------------------------
Add-Computer `
    -ComputerName $computer_name `
    -DomainName $domain_name `
    -Credential $admin_user `
    -Restart `
    -Force 

#----------------------------------------------------------------------------
# 03. - Chocolately installieren
#----------------------------------------------------------------------------
# set tsl secuerity protocol
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Set-ExecutionPolicy Bypass `
    -Scope Process `
    -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#----------------------------------------------------------------------------
# 04. Install Software
#     Since 2017 Reporting Services is its own download
#----------------------------------------------------------------------------
choco install googlechrome -y 
choco install ssrs -y --ignore-checksums

#----------------------------------------------------------------------------
# 05. Install ReportingServicesTools (PowerShell)
#     https://github.com/microsoft/ReportingServicesTools
#----------------------------------------------------------------------------
Install-Module ReportingServicesTools

#----------------------------------------------------------------------------
# 06. Configure Reporting Services
#----------------------------------------------------------------------------
Set-RsDatabase `
  -DatabaseServerName $database_servername `
  -Name $report_servername `
  -ReportServerInstance $report_serverinstance `
  -DatabaseCredentialType ServiceAccount `
  -ReportServerVersion SQLServer2017
 
Set-RsUrlReservation `
  -SqlServerVersion $sqlserver_version `
  -ReportServerInstance $report_serverinstance

#----------------------------------------------------------------------------
# 07. Open Firewall
#----------------------------------------------------------------------------
New-NetFirewallRule `
    -DisplayName 'HTTP' `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 80 `
    -Action Allow

#----------------------------------------------------------------------------
# 08. If it does not work: Restart Service
#----------------------------------------------------------------------------
Restart-Service `
    -DisplayName "SQL Server Reporting Services"

Backup-RSEncryptionKey `
    -ReportServerInstance $report_serverinstance `
    -Password $encryptionkey_pass `
    -KeyPath $encryptionkey_path `
    -SqlServerVersion $sqlserver_version