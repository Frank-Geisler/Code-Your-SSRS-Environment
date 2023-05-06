#============================================================================
#	Datei:		03 - Setup Win10 Client.ps1
#
#	Summary:	This script contains the steps to setup a Windows 10 Client
#
#	Date:	    2023-05-06
#
#   Revisions:  yyyy-dd-mm
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
# 00. Variablen
#----------------------------------------------------------------------------
$computer_name = 'client'
$domain_name = 'ssrs.net'
$admin_user = 'SSRS\fgeisler'

#--------------------------------------------------------------------------
# 01. Update Client
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
# 02. Add Computer to the Domain
# -------------------------------------------------------------------------
Add-Computer `
    -ComputerName $computer_name `
    -DomainName $domain_name `
    -Credential $admin_user `
    -Restart `
    -Force 

#----------------------------------------------------------------------------
# 03. Install Chocolately
#----------------------------------------------------------------------------
Set-ExecutionPolicy Bypass `
    -Scope Process `
    -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#----------------------------------------------------------------------------
# 04. Install Software
#----------------------------------------------------------------------------
choco install googlechrome -y 
choco install azure-data-studio -y
choco install vscode -y
choco install sql-server-management-studio -y
choco install docker-desktop -y
choco install git -params '"/GitAndUnixToolsOnPath"' -y
choco install gitkraken -y

#----------------------------------------------------------------------------
# 05. Install NavContainer Helper
#----------------------------------------------------------------------------
Install-Module `
    -Name 'NavContainerHelper'

# Check if it was installed correctly
Write-NavContainerHelperWelcomeText  

#----------------------------------------------------------------------------
# 06. Open Firwall for HTTP
#----------------------------------------------------------------------------
New-NetFirewallRule `
    -DisplayName 'HTTP' `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 80 `
    -Action Allow