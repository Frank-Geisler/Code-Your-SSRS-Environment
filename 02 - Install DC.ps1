#============================================================================
#	Datei:		02 - Setup Domain.ps1
#
#	Summary:	Install the Active Directory Domain on dc01
#
#	Datum:		2019-10-13
#
#   Revisionen: yyyy-dd-mm
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
$Domain = 'ssrs'
$DomainEnding = 'net'   
$DomainName = $Domain+'.'+$DomainEnding
$NewDomainNetbiosName = 'ssrs'
$DomainMode = 'WinThreshold'
$ForestMode = 'WinThreshold'
$SafeModeAdministratorPassword = ConvertTo-SecureString 'Pa$w0rd1' `
                                    -AsPlainText `
                                    -Force

#--------------------------------------------------------------------------
# 01. - Update Server
# -------------------------------------------------------------------------
Set-ExecutionPolicy `
  -ExecutionPolicy Unrestricted `
  -Force

Install-Module PSWindowsUpdate `
    -Force

Install-WindowsUpdate `
   -AcceptAll `
   -AutoReboot                                    

#----------------------------------------------------------------------------
# 02. - Install Domain
#----------------------------------------------------------------------------
Install-WindowsFeature `
    -name AD-Domain-Services `
    -IncludeManagementTools

Import-Module ADDSDeployment

Install-ADDSForest `
    -CreateDNSDelegation:$false `
    -SafeModeAdministratorPassword $SafeModeAdministratorPassword `
    -DomainName $DomainName `
    -DomainMode $DomainMode `
    -ForestMode $ForestMode `
    -DomainNetBiosName $NewDomainNetbiosName `
    -InstallDNS:$true `
    -Confirm:$false

#----------------------------------------------------------------------------
# 03. - Install Chocolately
#----------------------------------------------------------------------------
Set-ExecutionPolicy Bypass `
    -Scope Process `
    -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#----------------------------------------------------------------------------
# 04. Install Software
#----------------------------------------------------------------------------
choco install googlechrome -y    

#----------------------------------------------------------------------------
# 05. Create Users
#----------------------------------------------------------------------------
$AccountPath = 'CN=Users,DC=ssrs,DC=net'
$ReportUser_username = 'ReportUser'
$ReportUser_password = ConvertTo-SecureString 'Pa$w0rd1' `
                        -AsPlaintext `
                        -Force
$ReportUser_description = 'This is a Reporting Services User'

New-ADUser `
    -Path $AccountPath `
    -Name $ReportUser_username `
    -AccountPassword $ReportUser_password `
    -Description $ReportUser_description `
    -ChangePasswordAtLogon:$false `
    -CannotChangePassword:$true `
    -PasswordNeverExpires:$true `
    -Enabled:$true

#----------------------------------------------------------------------------
# 06. - AD-User ReportAdmin erstellen
#----------------------------------------------------------------------------
$AccountPath = 'CN=Users,DC=ssrs,DC=net'
$ReportAdmin_username = 'ReportAdmin'
$ReportAdmin_password = ConvertTo-SecureString 'Pa$w0rd1' `
                        -AsPlaintext `
                        -Force
$ReportAdmin_description = 'This is the Report Admin User'

New-ADUser `
    -Path $AccountPath `
    -Name $ReportAdmin_username `
    -AccountPassword $ReportAdmin_password `
    -Description $ReportAdmin_description `
    -ChangePasswordAtLogon:$false `
    -CannotChangePassword:$true `
    -PasswordNeverExpires:$true `
    -Enabled:$true