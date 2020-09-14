#============================================================================
#	Datei:		03 - Setup Win10 Client.ps1
#
#	Summary:	In diesem Script steht alles was man braucht um den Windows 10
#               Client zu installieren
#
#	Datum:		2019-10-13
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