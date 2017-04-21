<##########################################################################################################################################

Version :	0.1.0.0
Author  :	Gr33nDrag0n
History :	2017/04/21 - Release v0.1.0.0
			2017/04/20 - Creation of the script.

##########################################################################################################################################>


# Add Param: -Config
# Add Param: -NodeList
# Add Param: -NoBanner

Clear-Host

###########################################################################################################################################
#### Config File Verification

# Test Path
#if( Test-Path 

# Load in memory
$Private:MyConfig = Get-Content .\Config-Gr33nDrag0n.json | ConvertFrom-Json

# Test Required Account Values


$Private:MyAccount = $MyConfig.Account
Write-Host '#### Accounts #################################################################'
$MyAccount

###########################################################################################################################################


$Private:MyServerList = $MyConfig.Servers
Write-Host '#### ServerList ###############################################################'
$MyServerList

###########################################################################################################################################
#### Module Verification

# If module already in memory, remove it from memory. (Faster Dev.)
if( Get-Module -Name PsArk ) { Remove-Module PsArk }

# Load PsArk module.
if( Get-Module -ListAvailable | Where-Object { $_.Name -eq 'PsArk' } )
{
  #Import-Module PsArk –DisableNameChecking
  Import-Module PsArk
  Write-Host 'PsArk Module Loaded' -Foreground Green
}
else
{   
  Write-Host 'PsArk Module Not Found' -Foreground Red
  Exit
}


###########################################################################################################################################
#### Show Banner

Show-PsArkAbout

#### Configure API Server

# By default, my open api public node https://api.arknode.net/api/ is used by the module.
# Target node can be overwriten using:

Write-Host 'Set-PsArkConfiguration -URI "https://api.arknode.net/api/"' -Foreground Cyan
Set-PsArkConfiguration -URI $MyServerList[0]
Write-Host ''

#### API Call: Accounts

Write-Host 'Get-PsArkAccount -Address $Address' -Foreground Cyan
Get-PsArkAccount -Address $MyAccount.DelegateAddress | FL *

Write-Host 'Get-PsArkAccountBalance -Address $Address' -Foreground Cyan
Get-PsArkAccountBalance -Address $MyAccount.DelegateAddress | FL *

Write-Host 'Get-PsArkAccountPublicKey -Address $Address' -Foreground Cyan
Write-Host ''
Get-PsArkAccountPublicKey -Address $MyAccount.DelegateAddress
Write-Host ''

Write-Host 'Get-PsArkAccountVote -Address $Address' -Foreground Cyan
Get-PsArkAccountVote -Address $MyAccount.DelegateAddress | FL *

Write-Host "New-PsArkAccount -Secret 'New Account Password'" -Foreground Cyan
New-PsArkAccount -Secret 'New Account Password' | FL *

Write-Host 'Open-PsArkAccount -Secret $Secret' -Foreground Cyan
Open-PsArkAccount -Secret $MyAccount.DelegateSecret | FL *

#Write-Host 'Add-PsArkAccountVote ???'
#Add-PsArkAccountVote | FT

#Write-Host 'Remove-PsArkAccountVote ???'
#Remove-PsArkAccountVote | FT

#### API Call: Loader

Write-Host 'Get-PsArkLoadingStatus' -Foreground Cyan
Get-PsArkLoadingStatus | FL *

Write-Host 'Get-PsArkSyncStatus' -Foreground Cyan
Get-PsArkSyncStatus | FL *