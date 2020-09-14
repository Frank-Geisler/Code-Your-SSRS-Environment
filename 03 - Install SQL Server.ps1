#============================================================================
#   File:		  03 - Setup SQL Server.ps1
#
#	  Summary:	This script brings the sql server into the domain
#
#	  Date:		  2019-10-13
#
#   Revisionen: yyyy-dd-mm
#
#	  Project:	SQL Saturday Oregon 2019
#
#	  PowerShell Version: 5.1
#------------------------------------------------------------------------------
# Written by
# Frank Geisler, GDS Business Intelligence GmbH
#
# This script is intended only as a supplement to demos and lectures
#	given by Frank Geisler.  
#  
#	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
#	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
#	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
#	PARTICULAR PURPOSE.
#============================================================================*/



#----------------------------------------------------------------------------
# 00. Variables
#----------------------------------------------------------------------------
$computer_name = 'sql'
$domain_name = 'ssrs.net'
$admin_user = 'SSRS\fgeisler'

# ReportServer
$database_servername = 'localhost'
$report_servername = 'ReportServer'
$report_serverinstance = 'SSRS'
$sqlserver_version = 'SQLServer2017'

# Encryption Key
$encryptionkey_pass = 'Pa$$w0rd1'
$encryptionkey_path = $env:USERPROFILE+'\Documents\ssrs_key.snk'

#--------------------------------------------------------------------------
# 01. - update sql vm
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
# 02. - join computer to the domain
# -------------------------------------------------------------------------
Add-Computer `
    -ComputerName $computer_name `
    -DomainName $domain_name `
    -Credential $admin_user `
    -Restart `
    -Force 

#----------------------------------------------------------------------------
# 03. - install Chocolately 
#----------------------------------------------------------------------------
Set-ExecutionPolicy Bypass `
    -Scope Process `
    -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#----------------------------------------------------------------------------
# 04. Install Software
#     Since 2017 Reporting Services is its own download
#----------------------------------------------------------------------------
choco install googlechrome -y 
choco install ssrs -y

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
 
Set-RsUrlReservation `
  -SqlServerVersion $sqlserver_version `
  -ReportServerInstance $report_serverinstance

#----------------------------------------------------------------------------
# 07. Open Firewall
#----------------------------------------------------------------------------
New-NetFirewallRule `
    -DisplayName 'HTTP' `
    -Direction Inbound `
    –Protocol TCP `
    –LocalPort 80 `
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