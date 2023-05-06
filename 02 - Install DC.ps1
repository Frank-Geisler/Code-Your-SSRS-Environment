#============================================================================
#	File:	  02 - Setup Domain.ps1
#
#	Summary:  Install the Active Directory Domain on dc01
#
#	Date:	  2023-05-06
#
#   Revision: yyyy-dd-mm
#
#	Project:  SQL Saturday New York City 2023
#
#	PowerShell Version: 5.1
#------------------------------------------------------------------------------
# Written by
#   Frank Geisler, GDS Business Intelligence GmbH
#
# THIS CODE AND THE INFORMATION CONTAINED HEREIN ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND.
# NATURE, EXPRESS OR IMPLIED, INCLUDING,
# BUT NOT LIMITED TO FUNCTIONALITY OR FITNESS FOR A PARTICULAR
# PURPOSE. YOU USE THE CODE AT YOUR OWN RISK.
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
# 01. Update Server
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
# 02. Install Domain
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
# 03. Install Chocolately
#----------------------------------------------------------------------------
# Set TSL secuerity protocol
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

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
# 06. Create AD-User ReportAdmin
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