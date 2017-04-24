<##########################################################################################################################################

Version :	0.1.0.0
Author  :	Gr33nDrag0n
History :	2017/04/24 - Release v0.1.0.0
			2017/04/20 - Creation of the script.

##########################################################################################################################################>

[CmdletBinding()]
Param(
	[parameter(Mandatory = $True)]
	[ValidateSet('ALL','Account','Loader','Transaction','Peer','Block','Delegate','MultiSig')]
	[System.String] $Test,
	
	[parameter(Mandatory = $False)]
	[System.String] $ConfigFile = '.\Config-Gr33nDrag0n.json'
	)

###########################################################################################################################################
#### Init.

Clear-Host


###########################################################################################################################################
#### Config File Verification

# Test Path
if( $( Test-Path $ConfigFile ) -eq $False )
{
	Write-Warning 'Config. File NOT FOUND !'
	Exit
}

# Load in memory
Try {
	$Private:MyConfig = Get-Content $ConfigFile | ConvertFrom-Json
}
Catch {
	Write-Warning 'Config. File ConvertFrom-Json FAILED !'
	Exit
}


###########################################################################################################################################
#### Module Verification

# If module already in memory, remove it from memory.
if( Get-Module -Name PsArk ) { Remove-Module PsArk }

# Load PsArk module.
if( Get-Module -ListAvailable | Where-Object { $_.Name -eq 'PsArk' } )
{
  Import-Module PsArk
}
else
{   
  Write-Warning 'PsArk Module Not Found'
  Exit
}


###########################################################################################################################################
#### MAIN

Show-PsArkAbout

Write-Host ''
Write-Host '##### LOADED CONFIGURATION ##########################################################' -Foreground Yellow

$MyConfig.Account
$MyConfig.Servers

if( ( $Test -eq 'ALL' ) -or ( $Test -eq 'Account' ) )
{
	Write-Host ''
	Write-Host '##### API Call: ACCOUNT #############################################################' -Foreground Yellow
	Write-Host ''

	Write-Host "Command: Get-PsArkAccount -URL $($MyConfig.Servers[0]) -Address $($MyConfig.Account.DelegateAddress)" -Foreground Cyan
	Get-PsArkAccount -URL $MyConfig.Servers[0] -Address $MyConfig.Account.DelegateAddress | FL *

	#Get-PsArkAccountBalance                             
	#Get-PsArkAccountPublicKey                           
	#Get-PsArkAccountVote                                
	#Get-PsArkAccountSecondSignature                     

	#New-PsArkAccount                                    
	#Open-PsArkAccount                                   
	#Add-PsArkAccountVote                                
	#Remove-PsArkAccountVote                             
	#Add-PsArkAccountSecondSignature                     
}

if( ( $Test -eq 'ALL' ) -or ( $Test -eq 'Loader' ) )
{
		Write-Host ''
	Write-Host '##### API Call: LOADER ##############################################################' -Foreground Yellow
	Write-Host ''

	ForEach( $Private:Server in $MyConfig.Servers )
	{
		Write-Host "### $Server" -Foreground Yellow
		Write-Host ''
		
		Write-Host "Command: Get-PsArkLoadingStatus -URL $Server" -Foreground Cyan
		Get-PsArkLoadingStatus -URL $Server | FL *

		Write-Host "Command: Get-PsArkSyncStatus -URL $Server" -Foreground Cyan
		Get-PsArkSyncStatus -URL $Server | FL *

		Write-Host "Command: Get-PsArkBlockReceiptStatus -URL $Server" -Foreground Cyan
		Write-Host ''
		Get-PsArkBlockReceiptStatus -URL $Server | FL *
		Write-Host ''
	}
}

if( ( $Test -eq 'ALL' ) -or ( $Test -eq 'Transaction' ) )
{
	Write-Host ''
	Write-Host '##### API Call: TRANSACTION #########################################################' -Foreground Yellow
	Write-Host ''

	#Get-PsArkTransaction                                
	#Get-PsArkTransactionList                            
	#Get-PsArkTransactionUnconfirmed                     
	#Get-PsArkTransactionUnconfirmedList                 

	#Send-PsArkTransaction                               
}

if( ( $Test -eq 'ALL' ) -or ( $Test -eq 'Peer' ) )
{
	Write-Host ''
	Write-Host '##### API Call: PEER ################################################################' -Foreground Yellow
	Write-Host ''

	#Get-PsArkPeer                                       
	#Get-PsArkPeerList                                   
	#Get-PsArkPeerListVersion                            
}

if( ( $Test -eq 'ALL' ) -or ( $Test -eq 'Block' ) )
{
	Write-Host ''
	Write-Host '##### API Call: BLOCK ###############################################################' -Foreground Yellow
	Write-Host ''

	#Get-PsArkBlock                                      
	#Get-PsArkBlockList                                  
	#Get-PsArkBlockFee                                   
	#Get-PsArkBlockHeight                                
	#Get-PsArkBlockForged                                
}

if( ( $Test -eq 'ALL' ) -or ( $Test -eq 'Delegate' ) )
{
	Write-Host ''
	Write-Host '##### API Call: DELEGATE ############################################################' -Foreground Yellow
	Write-Host ''

	#Get-PsArkDelegate                                   
	#Get-PsArkDelegateList                               
	#Get-PsArkDelegateVoterList                          

	#Enable-PsArkDelegate                                
	#Or
	#New-PsArkDelegate                                   

	#Enable-PsArkDelegateForging                         
	#Disable-PsArkDelegateForging                        
}

if( ( $Test -eq 'ALL' ) -or ( $Test -eq 'MultiSig' ) )
{
	Write-Host ''
	Write-Host '##### API Call: MULTI-SIGNATURE #####################################################' -Foreground Yellow
	Write-Host ''

	#Get-PsArkMultiSigPendingTransactionList             
	#Get-PsArkMultiSigAccountList                        

	#New-PsArkMultiSigAccount                            
	#Sign-PsArkMultiSigTransaction                       
}
