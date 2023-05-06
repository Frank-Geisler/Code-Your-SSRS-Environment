#============================================================================
#	File:		01 - Setup Azure Environment.ps1
#
#	Summary:	This script sets up a full environment for Reporting Services
#               Development in Azure
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
# 00. Variables
#----------------------------------------------------------------------------
$SubscriptionName = 'MVP Sponsorship'
$resourcegroupName = 'ssrsdemo'
$location = 'West US'

# Storage
$storageName = 'ssrsnycsqlsat'
$storageType = 'Standard_LRS'

# Network
$vnetName = 'vnet-ssrsnyc'
$subNetName = 'snet-default'
$VNetAddressPrefix = '10.0.0.0/16'
$VNetSubnetAddressPrefix = '10.0.0.0/24'

# Compute for dc01
$dc01_publisherName = 'MicrosoftWindowsServer'
$dc01_offer = 'WindowsServer'
$dc01_sku = '2016-Datacenter'
$dc01_os_Version = 'latest'
$dc01_VMName = 'dc01'
$dc01_VMSize = 'Standard_E4s_v3'
$dc01_OSDiskName = 'osdisk_'+$dc01_VMName
$dc01_InterfaceName = 'nic_'+$dc01_VMName
$dc01_PipName = 'pip_'+$dc01_VMName

# Compute for sql
$sql_publisherName = 'MicrosoftSQLServer'
$sql_offer = 'SQL2017-WS2016'
$sql_sku = 'SQLDEV'
$sql_os_Version = 'latest'
$sql_VMName = 'sql'
$sql_VMSize = 'Standard_E4s_v3'
$sql_OSDiskName = 'osdisk_'+$sql_VMName
$sql_InterfaceName = 'nic_'+$sql_VMName
$sql_PipName = 'pip_'+$sql_VMName

# Compute for client
$client_publisherName = 'MicrosoftWindowsDesktop'
$client_offer = 'Windows-10'
$client_sku = '19h1-pro'
$client_os_Version = 'latest'
$client_VMName = 'client'
$client_VMSize = 'Standard_E4s_v3'
$client_OSDiskName = 'osdisk_'+$client_VMName
$client_InterfaceName = 'nic_'+$client_VMName
$client_PipName = 'pip_'+$client_VMName

#--------------------------------------------------------------------------
# 01. Login to Azure
# -------------------------------------------------------------------------
Login-AzureRmAccount
Get-AzureRmSubscription `
   -SubscriptionName $SubscriptionName | Set-AzureRmContext

#--------------------------------------------------------------------------
# 02. Create Resource Group
# -------------------------------------------------------------------------
New-AzureRmResourceGroup `
    -Name $resourcegroupName `
    -Location $location

#----------------------------------------------------------------------------
# 03. Create Storage
#     The name in $storageName must be unique
#----------------------------------------------------------------------------
$storageAccount = New-AzureRmStorageAccount `
                         -ResourceGroupName $resourcegroupName `
                         -Name $storageName `
                         -Type $StorageType `
                         -Location $location

#----------------------------------------------------------------------------
# 04. Create VNet
#----------------------------------------------------------------------------
$SubnetConfig = New-AzureRmVirtualNetworkSubnetConfig `
                      -Name $subNetName `
                      -AddressPrefix $VNetSubnetAddressPrefix

$vn = New-AzureRmVirtualNetwork `
             -Name $VNetName `
             -ResourceGroupName $ResourceGroupName `
             -Location $Location `
             -AddressPrefix $VNetAddressPrefix `
             -Subnet $SubnetConfig

#----------------------------------------------------------------------------
# 05. Reading credentails from the user. Here you could also get credentials
#     from the Azure Key Vault
#     ssmsadmin
#     !test1234567890    
#----------------------------------------------------------------------------
$Credential = Get-Credential

#--------------------------------------------------------------------------
# 06. Create virtual machine dc01
# -------------------------------------------------------------------------

# Create Public IP-Adresse
$pip_dc01 = New-AzureRmPublicIpAddress `
                -Name $dc01_PipName `
                -ResourceGroupName $resourcegroupName `
                -Location $location `
                -AllocationMethod Dynamic

# Create Network Interface
$nic_dc01 = New-AzureRmNetworkInterface `
                        -Name $dc01_InterfaceName `
                        -ResourceGroupName $resourcegroupName `
                        -Location $location `
                        -SubnetId $vn.Subnets[0].Id `
                        -PublicIpAddressId $pip_dc01.Id

# Creating the Configuration for the VM
$vmConfig_dc01 = New-AzureRmVMConfig `
                        -VMName $dc01_VMName `
                        -VMSize  $dc01_VMSize | `
                        Set-AzureRmVMOperatingSystem `
                            -Windows `
                            -ComputerName $dc01_VMName `
                            -Credential $Credential | `
                            Add-AzureRmVMNetworkInterface `
                                -Id $nic_dc01.Id | `
                                Set-AzureRmVMOSDisk `
                                    -Name $dc01_OSDiskName `
                                    -CreateOption FromImage | `
                                    Set-AzureRmVMBootDiagnostics `
                                        -Enable `
                                        -ResourceGroupName $resourcegroupName `
                                        -StorageAccountName $storageName ` |
                                        Set-AzureRmVMSourceImage `
                                            -PublisherName $dc01_publisherName `
                                            -Offer $dc01_offer `
                                            -Skus $dc01_sku `
                                            -Version $dc01_os_Version

# Create the Virtual Machine
New-AzureRmVM `
    -ResourceGroupName $resourcegroupName `
    -Location $location `
    -VM $vmConfig_dc01

#--------------------------------------------------------------------------
# 06. Create virtual machine sql
# -------------------------------------------------------------------------

# Create Public IP-Adresse
$pip_sql = New-AzureRmPublicIpAddress `
                -Name $sql_PipName `
                -ResourceGroupName $resourcegroupName `
                -Location $location `
                -AllocationMethod Dynamic

# Create Network Interface
$nic_sql = New-AzureRmNetworkInterface `
                        -Name $sql_InterfaceName `
                        -ResourceGroupName $resourcegroupName `
                        -Location $location `
                        -SubnetId $vn.Subnets[0].Id `
                        -PublicIpAddressId $pip_sql.Id

# Creating the Configuration for the VM
$vmConfig_sql = New-AzureRmVMConfig `
                        -VMName $sql_VMName `
                        -VMSize  $sql_VMSize | `
                        Set-AzureRmVMOperatingSystem `
                            -Windows `
                            -ComputerName $sql_VMName `
                            -Credential $Credential | `
                            Add-AzureRmVMNetworkInterface `
                                -Id $nic_sql.Id | `
                                Set-AzureRmVMOSDisk `
                                    -Name $sql_OSDiskName `
                                    -CreateOption FromImage | `
                                    Set-AzureRmVMBootDiagnostics `
                                        -Enable `
                                        -ResourceGroupName $resourcegroupName `
                                        -StorageAccountName $storageName ` |
                                        Set-AzureRmVMSourceImage `
                                            -PublisherName $sql_publisherName `
                                            -Offer $sql_offer `
                                            -Skus $sql_sku `
                                            -Version $sql_os_Version

# Create the Virtual Machine
New-AzureRmVM `
    -ResourceGroupName $resourcegroupName `
    -Location $location `
    -VM $vmConfig_sql

#--------------------------------------------------------------------------
# 07. Create virtual machine client
# -------------------------------------------------------------------------

# Create Public IP-Adresse
$pip_client = New-AzureRmPublicIpAddress `
                -Name $client_PipName `
                -ResourceGroupName $resourcegroupName `
                -Location $location `
                -AllocationMethod Dynamic

# Create Network Interface
$nic_client = New-AzureRmNetworkInterface `
                        -Name $client_InterfaceName `
                        -ResourceGroupName $resourcegroupName `
                        -Location $location `
                        -SubnetId $vn.Subnets[0].Id `
                        -PublicIpAddressId $pip_client.Id

# Creating the Configuration for the VM
$vmConfig_client = New-AzureRmVMConfig `
                        -VMName $client_VMName `
                        -VMSize  $client_VMSize | `
                        Set-AzureRmVMOperatingSystem `
                            -Windows `
                            -ComputerName $client_VMName `
                            -Credential $Credential | `
                            Add-AzureRmVMNetworkInterface `
                                -Id $nic_client.Id | `
                                Set-AzureRmVMOSDisk `
                                    -Name $client_OSDiskName `
                                    -CreateOption FromImage | `
                                    Set-AzureRmVMBootDiagnostics `
                                        -Enable `
                                        -ResourceGroupName $resourcegroupName `
                                        -StorageAccountName $storageName ` |
                                        Set-AzureRmVMSourceImage `
                                            -PublisherName $client_publisherName `
                                            -Offer $client_offer `
                                            -Skus $client_sku `
                                            -Version $client_os_Version

# Create the Virtual Machine
New-AzureRmVM `
    -ResourceGroupName $resourcegroupName `
    -Location $location `
    -VM $vmConfig_client
