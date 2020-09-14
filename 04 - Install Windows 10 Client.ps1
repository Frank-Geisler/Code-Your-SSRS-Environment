#============================================================================
#	File:		04 - Setup Win10 Client.ps1
#
#	Summary:	script to setup a Win 10 client
#
#	Date:		2019-10-13
#
#   Revisionen: yyyy-dd-mm
#                   - ...
#
#	Project:	SQL Saturday Oregon 2019
#
#	PowerShell Version: 5.1
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#	Written by
#   Frank Geisler, GDS Business Intelligence GmbH
#
#   This script is intended only as a supplement to demos and lectures
#	given by Frank Geisler.  
#  
#	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
#	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
#	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
#	PARTICULAR PURPOSE.
#============================================================================*/

#----------------------------------------------------------------------------
# 00. variables
#----------------------------------------------------------------------------
$computer_name = 'client'
$domain_name = 'ssrs.net'
$admin_user = 'SSRS\fgeisler'

#--------------------------------------------------------------------------
# 01. - update Client
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
# 02. - join Computer to domain
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
# 04. install some software 
#----------------------------------------------------------------------------
choco install googlechrome -y 
choco install azure-data-studio -y
choco install vscode -y
choco install sql-server-management-studio -y
choco install docker-desktop -y
choco install git -params '"/GitAndUnixToolsOnPath"' -y
choco install gitkraken -y

#----------------------------------------------------------------------------
# 05. install NavContainer Helper
#----------------------------------------------------------------------------
Install-Module `
    -Name 'NavContainerHelper'

# Check if module was installed properly
Write-NavContainerHelperWelcomeText  

#----------------------------------------------------------------------------
# 06. open Firewall for HTTP traffic
#----------------------------------------------------------------------------
New-NetFirewallRule `
    -DisplayName 'HTTP' `
    -Direction Inbound `
    –Protocol TCP `
    –LocalPort 80 `
    -Action Allow