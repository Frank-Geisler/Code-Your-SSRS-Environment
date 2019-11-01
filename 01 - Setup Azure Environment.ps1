#============================================================================
#	Datei:		01 - Setup Azure Environment.ps1
#
#	Summary:	This script sets up a full environment for Reporting Services
#               Development in Azure
#
#	Datum:		2019-11-01
#
#   Revisionen: yyyy-dd-mm
#                   - ...
#	Projekt:	SQL Saturday Oregon 2019
#
#	PowerShell Version: 5.1
#------------------------------------------------------------------------------
#	Geschrieben von 
#       Frank Geisler, GDS Business Intelligence GmbH
#
#   Dieses Script ist nur zu Lehr- bzw. Lernzwecken gedacht
#
#   DIESER CODE UND DIE ENTHALTENEN INFORMATIONEN WERDEN OHNE GEWÄHR JEGLICHER
#   ART ZUR VERFÜGUNG GESTELLT, WEDER AUSDRÜCKLICH NOCH IMPLIZIT, EINSCHLIESSLICH,
#   ABER NICHT BESCHRÄNKT AUF FUNKTIONALITÄT ODER EIGNUNG FÜR EINEN BESTIMMTEN
#   ZWECK. SIE VERWENDEN DEN CODE AUF EIGENE GEFAHR.
#============================================================================*/

#----------------------------------------------------------------------------
# 00. Variables
#----------------------------------------------------------------------------
$SubscriptionName = 'MVP Sponsorship'
$resourcegroupName = 'ssrsdemo'
$location = 'West US'

# Storage
$storageName = 'ssrsoregonsqlsat'
$storageType = 'Standard_LRS'

# Netzwerk
$vnetName = 'vnet-ssrsoregon'
$subNetName = 'snet-default'
$VNetAddressPrefix = '10.0.0.0/16'
$VNetSubnetAddressPrefix = '10.0.0.0/24'

# Compute für dc01
$dc01_publisherName = 'MicrosoftWindowsServer'
$dc01_offer = 'WindowsServer'
$dc01_sku = '2016-Datacenter'
$dc01_os_Version = 'latest'
$dc01_VMName = 'dc01'
$dc01_VMSize = 'Standard_E4s_v3'
$dc01_OSDiskName = 'osdisk_'+$dc01_VMName
$dc01_InterfaceName = 'nic_'+$dc01_VMName
$dc01_PipName = 'pip_'+$dc01_VMName

# Compute für sql
$sql_publisherName = 'MicrosoftSQLServer'
$sql_offer = 'SQL2017-WS2016'
$sql_sku = 'SQLDEV'
$sql_os_Version = 'latest'
$sql_VMName = 'sql'
$sql_VMSize = 'Standard_E4s_v3'
$sql_OSDiskName = 'osdisk_'+$sql_VMName
$sql_InterfaceName = 'nic_'+$sql_VMName
$sql_PipName = 'pip_'+$sql_VMName

# Compute für client
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
# 01. - Login to Azure
# -------------------------------------------------------------------------

Login-AzureRmAccount
Get-AzureRmSubscription `
   -SubscriptionName $SubscriptionName | Set-AzureRmContext

#--------------------------------------------------------------------------
# 02. - Create Resource Group
# -------------------------------------------------------------------------
New-AzureRmResourceGroup `
    -Name $resourcegroupName `
    -Location $location

#----------------------------------------------------------------------------
# 03. - Create Storage
#       The name in $storageName must be unique
#----------------------------------------------------------------------------

$storageAccount = New-AzureRmStorageAccount `
                         -ResourceGroupName $resourcegroupName `
                         -Name $storageName `
                         -Type $StorageType `
                         -Location $location

#----------------------------------------------------------------------------
# 04. - VNet anlegen
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
# 05. - Reading credentails from the user. Here you could also get credentials
#       from the Azure Key Vault
#       fgeisler
#       !sqloregon2019    
#----------------------------------------------------------------------------
$Credential = Get-Credential

#--------------------------------------------------------------------------
# 06. - virtuelle Maschine dc01 anlegen
# -------------------------------------------------------------------------

# Public IP-Adresse anlegen
$pip_dc01 = New-AzureRmPublicIpAddress `
                -Name $dc01_PipName `
                -ResourceGroupName $resourcegroupName `
                -Location $location `
                -AllocationMethod Dynamic

# Netzwerk-Interface anlegen
$nic_dc01 = New-AzureRmNetworkInterface `
                        -Name $dc01_InterfaceName `
                        -ResourceGroupName $resourcegroupName `
                        -Location $location `
                        -SubnetId $vn.Subnets[0].Id `
                        -PublicIpAddressId $pip_dc01.Id

# Jetzt wird die eigentliche VM angelegt
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

# virtuelle Maschine erzeugen
New-AzureRmVM `
    -ResourceGroupName $resourcegroupName `
    -Location $location `
    -VM $vmConfig_dc01

#--------------------------------------------------------------------------
# 06. - virtuelle Maschine sql anlegen
# -------------------------------------------------------------------------

# Public IP-Adresse anlegen
$pip_sql = New-AzureRmPublicIpAddress `
                -Name $sql_PipName `
                -ResourceGroupName $resourcegroupName `
                -Location $location `
                -AllocationMethod Dynamic

# Netzwerk-Interface anlegen
$nic_sql = New-AzureRmNetworkInterface `
                        -Name $sql_InterfaceName `
                        -ResourceGroupName $resourcegroupName `
                        -Location $location `
                        -SubnetId $vn.Subnets[0].Id `
                        -PublicIpAddressId $pip_sql.Id

# Jetzt wird die eigentliche VM angelegt
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

# virtuelle Maschine erzeugen
New-AzureRmVM `
    -ResourceGroupName $resourcegroupName `
    -Location $location `
    -VM $vmConfig_sql

#--------------------------------------------------------------------------
# 06. - virtuelle Maschine client anlegen
# -------------------------------------------------------------------------

# Public IP-Adresse anlegen
$pip_client = New-AzureRmPublicIpAddress `
                -Name $client_PipName `
                -ResourceGroupName $resourcegroupName `
                -Location $location `
                -AllocationMethod Dynamic

# Netzwerk-Interface anlegen
$nic_client = New-AzureRmNetworkInterface `
                        -Name $client_InterfaceName `
                        -ResourceGroupName $resourcegroupName `
                        -Location $location `
                        -SubnetId $vn.Subnets[0].Id `
                        -PublicIpAddressId $pip_client.Id

# Jetzt wird die eigentliche VM angelegt
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

# virtuelle Maschine erzeugen
New-AzureRmVM `
    -ResourceGroupName $resourcegroupName `
    -Location $location `
    -VM $vmConfig_client
