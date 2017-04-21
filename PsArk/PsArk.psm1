<##########################################################################################################################################

Version :	0.1.0.0
Author  :	Gr33nDrag0n
History :	2017/04/21 - Release v0.1.0.0
			2017/04/20 - Creation of the module.

#### PsArk Configuration ###########################################################

Set-PsArkConfiguration						v0.1.0.0 + Help

#### API Call Functions #############################################################

# Accounts #-------------------------------------------------------------------------

Get-PsArkAccount							v0.1.0.0 + Help
Get-PsArkAccountBalance						v0.1.0.0 + Help
Get-PsArkAccountPublicKey					v0.1.0.0 + Help
Get-PsArkAccountVote						v0.1.0.0 + Help
Get-PsArkAccountSecondSignature				Struct Only

New-PsArkAccount							v0.1.0.0 (Partial) + Help
Open-PsArkAccount							v0.1.0.0 + Help
Add-PsArkAccountVote						Struct Only
Remove-PsArkAccountVote						Struct Only
Add-PsArkAccountSecondSignature				Struct Only

# Loader #---------------------------------------------------------------------------

Get-PsArkLoadingStatus						Struct Only
Get-PsArkSyncStatus							Struct Only

# Transactions #---------------------------------------------------------------------

Get-PsArkTransaction						Struct Only
Get-PsArkTransactionList					Struct Only
Get-PsArkTransactionUnconfirmed				Struct Only
Get-PsArkTransactionUnconfirmedList			Struct Only

Send-PsArkTransaction						Struct Only

# Peers #----------------------------------------------------------------------------

Get-PsArkPeer								Struct Only
Get-PsArkPeerList							Struct Only
Get-PsArkPeerListVersion					Struct Only

# Blocks #---------------------------------------------------------------------------

Get-PsArkBlock								Struct Only
Get-PsArkBlockList							Struct Only
Get-PsArkBlockFee							Struct Only
Get-PsArkBlockHeight						Struct Only
Get-PsArkBlockForged						Struct Only

# Delegates #------------------------------------------------------------------------

Get-PsArkDelegate							Struct Only
Get-PsArkDelegateList						Struct Only
Get-PsArkDelegateVoterList					Struct Only

Enable-PsArkDelegate						Struct Only
Or
New-PsArkDelegate							Struct Only

Enable-PsArkDelegateForging					Struct Only
Disable-PsArkDelegateForging				Struct Only

# Multi-Signature #------------------------------------------------------------------

Get-PsArkMultiSigPendingTransactionList	N/A (Priority 3)
Get-PsArkMultiSigAccountList				N/A (Priority 3)

New-PsArkMultiSigAccount					N/A (Priority 3)
Sign-PsArkMultiSigTransaction				N/A (Priority 3)

#### Internal Functions #############################################################

Invoke-PsPsArkApiCall							v0.l.1.0
Export-PsArkCsv								N/A (Priority 5)
Export-PsArkJson							N/A (Priority 5)

#### Misc. Functions ################################################################

# Usage Ideas
Send-PsArkMultiTransaction	-NbPerBlock 2 -NbBlock 5 -ToAddress -FromAddress -FromPassphrase  -FromSecondPassphrase

Show-PsArkDelegateUsername					N/A (Priority 9)
Start-PsArkNetworkMonitor					N/A (Priority 3)

Show-PsArkAbout								v0.l.0.0

##########################################################################################################################################>

$Script:PsArk_URI = 'https://api.arknode.net/api/'

##########################################################################################################################################################################################################
### PsArk Configuration
##########################################################################################################################################################################################################

<#
.SYNOPSIS
	Set Default Parameters
	
.DESCRIPTION
	Use this function to define your own default value.
	
.PARAMETER URI
	(Optional) URL for Lisk API request. Try to use HTTPS if possible.

.PARAMETER Address
	(Optional) Account Address.
	Note: Default Public Key will also be updated.
	
.PARAMETER Passphrase
	(Optional) Account Passphrase.
	
.EXAMPLE
	Set-PsArkConfiguration -URI https://api.arknode.net/api/

.EXAMPLE
	Set-PsArkConfiguration -URI https://api.arknode.net/api/ -Address AHWHRAW7XREEMYCTXRX4YR2PAIQGTGRX2M
#>

Function Set-PsArkConfiguration
{
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $True)] [string] $URI
        )
        
    # TODO: add uri validation remove api or add missing trailing /
		
	$Script:PsArk_URI = $URI
}

##########################################################################################################################################################################################################
### API Call: Accounts
##########################################################################################################################################################################################################

<#
.SYNOPSIS
	API Call: Get informations about an account from address.
	
.DESCRIPTION
	Return an object with following properties:
	
    "address": "Address of account. String",
    "unconfirmedBalance": "Unconfirmed balance of account. Integer",
    "balance": "Balance of account. Integer",
    "publicKey": "Public key of account. Hex",
    "unconfirmedSignature": "If account enabled second signature, but it's still not confirmed. Boolean: true or false",
    "secondSignature": "If account enabled second signature. Boolean: true or false",
    "secondPublicKey": "Second signature public key. Hex"
	
.PARAMETER Address
	Address of account.
	
.EXAMPLE
	Get-PsArkAccount -Address AHWHRAW7XREEMYCTXRX4YR2PAIQGTGRX2M
#>

Function Get-PsArkAccount
{
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $False)]
        [System.String] $URI='',
		
        [parameter(Mandatory = $True)]
        [System.String] $Address
        )
    
    if( $URI -eq '' ) { $URI = $Script:PsArk_URI }
	
    $Private:Output = Invoke-PsPsArkApiCall -Method Get -URI $( $URI+'api/accounts?address='+$Address )
    if( $Output.success -eq $True ) { $Output.account }
}

##########################################################################################################################################################################################################

<#
.SYNOPSIS
	API Call: Get the balance of an account.
	
.DESCRIPTION
	Return an object with following properties:
	
	"Balance":     "Balance of account",
	"Balance_U":   "Unconfirmed balance of account"
	"Balance_C":   "Balance of account / 100000000",
	"Balance_UC":  "Unconfirmed balance of account / 100000000"
	
.PARAMETER Address
	Address of account.

.EXAMPLE
	Get-PsArkAccountBalance -Address AHWHRAW7XREEMYCTXRX4YR2PAIQGTGRX2M
#>

Function Get-PsArkAccountBalance
{
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $False)]
        [System.String] $URI='',
		
        [parameter(Mandatory = $True)]
        [System.String] $Address
        )
    
    if( $URI -eq '' ) { $URI = $Script:PsArk_URI }

    $Private:Output = Invoke-PsPsArkApiCall -Method Get -URI $( $URI+'api/accounts/getBalance/?address='+$Address )
    if( $Output.success -eq $True )
    {
        New-Object PSObject -Property @{
          'Balance_UC'  = $($Output.UnconfirmedBalance/100000000)
          'Balance_C'   = $($Output.Balance/100000000)
          'Balance_U'   = $Output.UnconfirmedBalance
          'Balance'     = $Output.Balance
        }
    }
}

##########################################################################################################################################################################################################

<#
.SYNOPSIS
	API Call: Get account public key.
	
.DESCRIPTION
	Get the public key of an account.
	
.PARAMETER Address
	Address of account.
	
.EXAMPLE
	Get-PsArkAccountPublicKey -Address AHWHRAW7XREEMYCTXRX4YR2PAIQGTGRX2M
#>

Function Get-PsArkAccountPublicKey
{
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $False)]
        [System.String] $URI='',
		
        [parameter(Mandatory = $True)]
        [System.String] $Address
        )
    
    if( $URI -eq '' ) { $URI = $Script:PsArk_URI }

    $Private:Output = Invoke-PsPsArkApiCall -Method Get -URI $( $URI+'api/accounts/getPublicKey?address='+$Address )
    if( $Output.success -eq $True ) { $Output.publicKey }
}

##########################################################################################################################################################################################################

<#
.SYNOPSIS
	API Call: Get votes by account address.
	
.DESCRIPTION
	Get votes statistics from other addresses to the account address.
	
.PARAMETER Address
	Address of account.

.EXAMPLE
	Get-PsArkAccountVote -Address AHWHRAW7XREEMYCTXRX4YR2PAIQGTGRX2M
#>

Function Get-PsArkAccountVote
{
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $False)]
        [System.String] $URI='',
		
        [parameter(Mandatory = $True)]
        [System.String] $Address
        )
    
    if( $URI -eq '' ) { $URI = $Script:PsArk_URI }

    $Private:Output = Invoke-PsPsArkApiCall -Method Get -URI $( $URI+'api/accounts/delegates?address='+$Address )
    if( $Output.success -eq $True ) { $Output.delegates }
}

##########################################################################################################################################################################################################

<#
Get second signature of account.

GET /api/signatures/get?id=id

id: Id of signature. (String)

Response
    "signature" : {
        "id" : "Id. String",
        "timestamp" : "TimeStamp. Integer",
        "publicKey" : "Public key of signature. hex",
        "generatorPublicKey" : "Public Key of Generator. hex",
        "signature" : [array],
        "generationSignature" : "Generation Signature"
    }
#>

Function Get-PsArkAccountSecondSignature
{

}

##########################################################################################################################################################################################################

<#
.SYNOPSIS
	API Call: Create a new account.
	
.DESCRIPTION
	A new account is created.
	Return an object with the following properties:

		"address": "Address of account. String",
		"publicKey": "Public key of account. Hex",
	
.PARAMETER Secret
	Secret key of account.
	
.EXAMPLE
	New-PsArkAccount -Secret 'soon control wild distance sponsor decrease cheap example avoid route ten pudding'
#>

Function New-PsArkAccount
{
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $True)] [string] $Secret
        )
	
	$Private:Output = Invoke-PsPsArkApiCall -Method Post -URI $( $Script:PsArk_URI+'accounts/generatePublicKey' ) -Body @{secret=$Secret}
	if( $Output.success -eq $True )
	{
		New-Object PSObject -Property @{
			'PublicKey'  = $Output.publicKey
			'Address'    = 'NOT CODED YET!'
			}
	}
}

##########################################################################################################################################################################################################

<#
.SYNOPSIS
	API Call: Get information about an account.
	
.DESCRIPTION
	Get information about an account.
	Return an object with the following properties:

		"address": "Address of account. String",
		"unconfirmedBalance": "Unconfirmed balance of account. Integer",
		"balance": "Balance of account. Integer",
		"publicKey": "Public key of account. Hex",
		"unconfirmedSignature": "If account enabled second signature, but it's still not confirmed. Boolean: true or false",
		"secondSignature": "If account enabled second signature. Boolean: true or false",
		"secondPublicKey": "Second signature public key. Hex",
		"username": "Username of account."
	
.PARAMETER Secret
	Secret key of account.
	
.EXAMPLE
	Open-PsArkAccount -Secret 'soon control wild distance sponsor decrease cheap example avoid route ten pudding'
#>

Function Open-PsArkAccount
{
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $True)] [string] $Secret
        )
	
	$Private:Output = Invoke-PsPsArkApiCall -Method Post -URI $( $Script:PsArk_URI+'accounts/open' ) -Body @{secret=$Secret}
	if( $Output.success -eq $True ) { $Output.account }
}

##########################################################################################################################################################################################################

<#
Vote for the selected delegates. Maximum of 33 delegates at once.
PUT /api/accounts/delegates

Request
    "secret" : "Secret key of account",
    "publicKey" : "Public key of sender account, to verify secret passphrase in wallet. Optional, only for UI",
    "secondSecret" : "Secret key from second transaction, required if user uses second signature",
    "delegates" : "Array of string in the following format: ["+DelegatePublicKey"] OR ["-DelegatePublicKey"]. Use + to UPvote, - to DOWNvote"

Response
    "success": true,
    "transaction": {object}
#>

Function Add-PsArkAccountVote
{
	# Add support for PublickKey, Address, Delegate Name
	# Validate NbEntry >=1 && <= 33
}

##########################################################################################################################################################################################################

<#
Vote for the selected delegates. Maximum of 33 delegates at once.
PUT /api/accounts/delegates

Request
    "secret" : "Secret key of account",
    "publicKey" : "Public key of sender account, to verify secret passphrase in wallet. Optional, only for UI",
    "secondSecret" : "Secret key from second transaction, required if user uses second signature",
    "delegates" : "Array of string in the following format: ["+DelegatePublicKey"] OR ["-DelegatePublicKey"]. Use + to UPvote, - to DOWNvote"

Response
    "success": true,
    "transaction": {object}
#>

Function Remove-PsArkAccountVote
{
	# Add support for PublickKey, Address, Delegate Name
}

##########################################################################################################################################################################################################

<#
Add second signature to account.

PUT /api/signatures

Request
  "secret": "secret key of account",
  "secondsecret": "second key of account",
  "publicKey": "optional, to verify valid secret key and account"

Response
  "transactionId": "id of transaction with new signature",
  "publicKey": "Public key of signature. hex"
#>

Function Add-PsArkSecondSignature
{

}

##########################################################################################################################################################################################################
### API Call: Loader
##########################################################################################################################################################################################################

<#
Returns account's delegates by address.

GET /api/loader/status

   "success": true,
   "loaded": "Is blockchain loaded? Boolean: true or false",
   "now": "Last block loaded during loading time. Integer",
   "blocksCount": "Total blocks count in blockchain at loading time. Integer"
#>

Function Get-PsArkLoadingStatus
{   

}

##########################################################################################################################################################################################################

<#
Get the synchronisation status of the client.

GET /api/loader/status/sync

Response
   "success": true,
   "sync": "Is wallet is syncing with another peers? Boolean: true or false",
   "blocks": "Number of blocks remaining to sync. Integer",
   "height": "Total blocks in blockchain. Integer"
#>

Function Get-PsArkSyncStatus
{
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $False)]
        [System.String] $URI=''
        )
	
    if( $URI -eq '' ) { $URI = $Script:PsArk_URI }
    
    $Private:Output = Invoke-PsPsArkApiCall -Method Get -URI $( $URI+'api/loader/status/sync' )
    if( $Output.success -eq $True )
    {
      $Output | Select-Object -Property Syncing, Blocks, Height
    }
}

##########################################################################################################################################################################################################
### API Call: Transactions
##########################################################################################################################################################################################################

<#
Get transaction matched by id.

GET /api/transactions/get?id=id

id: String of transaction (String)

Response
	"transaction": {
		"id": "Id of transaction. String",
		"type": "Type of transaction. Integer",
		"subtype": "Subtype of transaction. Integer",
		"timestamp": "Timestamp of transaction. Integer",
		"senderPublicKey": "Sender public key of transaction. Hex",
		"senderId": "Address of transaction sender. String",
		"recipientId": "Recipient id of transaction. String",
		"amount": "Amount. Integer",
		"fee": "Fee. Integer",
		"signature": "Signature. Hex",
		"signSignature": "Second signature. Hex",
		"companyGeneratorPublicKey": "If transaction was sent to merchant, provided comapny generator public key to find company. Hex",
		"confirmations": "Number of confirmations. Integer"
	}
#>

Function Get-PsArkTransaction
{

}

##########################################################################################################################################################################################################

<#
Get list of transactions

Transactions list matched by provided parameters.

GET /api/transactions?blockId=blockId&senderId=senderId&recipientId=recipientId&limit=limit&offset=offset&orderBy=field

    blockId: Block id of transaction. (String)
    senderId: Sender address of transaction. (String)
    recipientId: Recipient of transaction. (String)
    limit: Limit of transaction to send in response. Default is 20. (Number)
    offset: Offset to load. (Integer number)
    orderBy: Name of column to order. After column name must go "desc" or "acs" to choose order type, prefix for column name is t_. Example: orderBy=t_timestamp:desc (String)

All parameters joins by "OR".

Example:
/api/transactions?blockId=10910396031294105665&senderId=6881298120989278452C&orderBy=timestamp:desc looks like: blockId=10910396031294105665 OR senderId=6881298120989278452C

Response
	"transactions": [
		"list of transactions objects"
#>

Function Get-PsArkTransactionList
{

}

##########################################################################################################################################################################################################

<#
Get unconfirmed transaction by id.

GET /api/transactions/unconfirmed/get?id=id

id: String of transaction (String)

Response
	"transaction": {
		"id": "Id of transaction. String",
		"type": "Type of transaction. Integer",
		"subtype": "Subtype of transaction. Integer",
		"timestamp": "Timestamp of transaction. Integer",
		"senderPublicKey": "Sender public key of transaction. Hex",
		"senderId": "Address of transaction sender. String",
		"recipientId": "Recipient id of transaction. String",
		"amount": "Amount. Integer",
		"fee": "Fee. Integer",
		"signature": "Signature. Hex",
		"signSignature": "Second signature. Hex",
		"confirmations": "Number of confirmations. Integer"
#>

Function Get-PsArkTransactionUnconfirmed
{

}

##########################################################################################################################################################################################################

<#
Get list of unconfirmed transactions

GET /api/transactions/unconfirmed

Response
    "transactions" : [list of transaction objects]
#>

Function Get-PsArkTransactionUnconfirmedList
{

}

##########################################################################################################################################################################################################

<#
Send transaction to broadcast network.

PUT /api/transactions

Request
    "secret" : "Secret key of account",
    "amount" : /* Amount of transaction * 10^8. Example: to send 1.1234 LISK, use 112340000 as amount */,
    "recipientId" : "Recipient of transaction. Address or username.",
    "publicKey" : "Public key of sender account, to verify secret passphrase in wallet. Optional, only for UI",
    "secondSecret" : "Secret key from second transaction, required if user uses second signature"

Response
	"transactionId": "id of added transaction"
#>

Function Send-PsArkTransaction
{

}

##########################################################################################################################################################################################################
### API Call: Peers
##########################################################################################################################################################################################################

<#
Get peer

Get peer by ip and port

GET /api/peers/get?ip=ip&port=port

    ip: Ip of peer. (String)
    port: Port of peer. (Integer)

Response

{
  "success": true,
  "peer": "peer object"
}
#>

Function Get-PsArkPeer
{
	$Private:Output = Invoke-PsPsArkApiCall -Method Get -URI $( $Script:PsArk_URI+'peers' )
	if( $Output.success -eq $True ) { $Output.peers }
}

##########################################################################################################################################################################################################

<#
Get peers list

Get peers list by parameters.

GET /api/peers?state=state&os=os&shared=shared&version=version&limit=limit&offset=offset&orderBy=orderBy

    state: State of peer. 1 - disconnected. 2 - connected. 0 - banned. (String)
    os: OS of peer. (String)
    shared: Is peer shared? Boolean: true or false. (String)
    version: Version of peer. (String)
    limit: Limit to show. Max limit is 100. (Integer)
    offset: Offset to load. (Integer)
    orderBy: Name of column to order. After column name must go "desc" or "acs" to choose order type. (String)

All parameters joins by "OR".

Example:
/api/peers?state=1&version=0.1.8 looks like: state=1 OR version=0.1.8

Response
  "peers": ["list of peers"]
#>

Function Get-PsArkPeerList
{

}

##########################################################################################################################################################################################################

<#
Get peer version and build time

GET /api/peers/version

Response
  "version": "version of Lisk",
  "build": "time of build"
#>

Function Get-PsArkPeerListVersion
{

}

##########################################################################################################################################################################################################
### API Call: Blocks
##########################################################################################################################################################################################################

<#
Get block by id.

GET /api/blocks/get?id=id

    id: Id of block.

Response
    "block": {
        "id": "Id of block. String",
        "version": "Version of block. Integer",
        "timestamp": "Timestamp of block. Integer",
        "height": "Height of block. Integer",
        "previousBlock": "Previous block id. String",
        "numberOfRequests": "Not using now. Will be removed in 0.2.0",
        "numberOfTransactions": "Number of transactions. Integer",
        "numberOfConfirmations": "Not using now.",
        "totalAmount": "Total amount of block. Integer",
        "totalFee": "Total fee of block. Integer",
        "payloadLength": "Payload length of block. Integer",
        "requestsLength": "Not using now. Will be removed in 0.2.0",
        "confirmationsLength": "Not using now.,
        "payloadHash": "Payload hash. Hex",
        "generatorPublicKey": "Generator public key. Hex",
        "generatorId": "Generator id. String.",
        "generationSignature": "Generation signature. Not using. Will be removed in 0.2.0",
        "blockSignature": "Block signature. Hex"
    }
#>

Function Get-PsArkBlock
{

}

##########################################################################################################################################################################################################

<#
Get all blocks.

GET /api/blocks?generatorPublicKey=generatorPublicKey&height=height&previousBlock=previousBlock&totalAmount=totalAmount&totalFee=totalFee&limit=limit&offset=offset&orderBy=orderBy

All parameters joins by OR.

Example:
/api/blocks?height=100&totalAmount=10000 looks like: height=100 OR totalAmount=10000

    totalFee: total fee of block. (Integer)
    totalAmount: total amount of block. (Integer)
    previousBlock: previous block of need block. (String)
    height: height of block. (Integer)
    generatorPublicKey: generator id of block in hex. (String)
    limit: limit of blocks to add to response. Default to 20. (Integer)
    offset: offset to load blocks. (Integer)
    orderBy: field name to order by. Format: fieldname:orderType. Example: height:desc, timestamp:asc (String)

Response
  "blocks": [
    "array of blocks"
  ]
#>

Function Get-PsArkBlockList
{

}

##########################################################################################################################################################################################################

<#
Get blockchain fee percent

GET /api/blocks/getFee

Response
  "fee": "fee percent"
#>

Function Get-PsArkBlockFee
{

}

##########################################################################################################################################################################################################

<#
Get blockchain height.

GET /api/blocks/getHeight

Response
  "height": "Height of blockchain. Integer"
#>

Function Get-PsArkBlockHeight
{

}

##########################################################################################################################################################################################################

<#
Get amount forged by account.

GET /api/delegates/forging/getForgedByAccount?generatorPublicKey=generatorPublicKey

generatorPublicKey: generator id of block in hex. (String)

Response
  "sum": "Forged amount. Integer"
#>

Function Get-PsArkBlockForged
{

}

##########################################################################################################################################################################################################
### API Call: Delegates
##########################################################################################################################################################################################################

<#
Get delegate by transaction id.

GET /api/delegates/get?id=transactionId

transactionId: Id of transaction where delegated was putted. (String)

Response
    "delegate":
        "username": "username of delegate",
        "transactionId": "transaction id",
        "votes": "amount of stake voted for this delegate"
#>

Function Get-PsArkDelegate
{

}

##########################################################################################################################################################################################################

<#
Get delegates list.

GET /api/delegates?limit=limit&offset=offset&orderBy=orderBy

    limit: Limit to show. Integer. Maximum is 100. (Integer)
    offset: Offset (Integer)
    orderBy: Order by field (String)

Response
  delegates objects array"
	Object includes:
		delegateId,
		address,
		publicKey,
		vote (# of votes),
		producedBlocks,
		missedBlocks,
		rate,
		productivity
#>

Function Get-PsArkDelegateList
{

}

##########################################################################################################################################################################################################

<#
Get voters of delegate.

GET /api/delegates/voters?publicKey=publicKey

publicKey: Public key of delegate. (String)

Response
  "accounts": [
    "array of accounts who vote for delegate"
  ]
#>

Function Get-PsArkDelegateVoterList
{

}

##########################################################################################################################################################################################################

<#
Enable delegate on account
Calls for delegates functional.

PUT /api/delegates

Request
  "secret": "Secret key of account",
  "secondSecret": "Second secret of account",
  "username": "Username of delegate. String from 1 to 20 characters."

Response
  "transaction": "transaction object"

Function Enable-PsArkDelegate
{

}

OR

Function New-PsArkDelegate
{

}
#>

##########################################################################################################################################################################################################

<#
Enable forging on delegate

POST /api/delegates/forging/enable

Request
  "secret": "secret key of delegate account"

Response
  "address": "address"
#>

Function Enable-PsArkDelegateForging
{

}

##########################################################################################################################################################################################################

<#
Disable forging on delegate

POST /api/delegates/forging/disable

Request
  "secret": "secret key of delegate account"

Response
  "address": "address"
#>

Function Disable-PsArkDelegateForging
{

}

##########################################################################################################################################################################################################
### API Call: Multi-Signature
##########################################################################################################################################################################################################

<#
Get pending multi-signature transactions
Return multisig transaction that waiting for your signature.

GET /api/multisignatures/pending?publicKey=publicKey

publicKey: Public key of account (String)

Response
    "transactions": ['array of transactions to sign']
#>

Function Get-PsArkMultiSigPendingTransactionList
{

}

##########################################################################################################################################################################################################

<#
Get accounts of multisignature.

GET /api/multisignatures/accounts?publicKey=publicKey

publicKey: Public key of multi-signature account (String)

Response
  "accounts": "array of accounts"
#>

Function Get-PsArkMultiSigAccountList
{

}

##########################################################################################################################################################################################################

<#
Create multi-signature account

PUT /api/multisignatures

Request
    "secret": "your secret. string. required.",
    "lifetime": "request lifetime in hours (1-24). required.",
    "min": "minimum signatures needed to approve a tx or a change (1-15). integer. required",
    "keysgroup": [array of public keys strings]. add '+' before publicKey to add an account or '-' to remove. required. 

Response
  "transactionId": "transaction id"
#>

Function New-PsArkMultiSigAccount
{

}

##########################################################################################################################################################################################################

<#
Sign transaction that wait for your signature.

POST /api/multisignatures/sign

Request
  "secret": "your secret. string. required.",
  "publicKey": "public key of your account. string. optional.",
  "transactionId": "id of transaction to sign"

Response
  "transactionId": "transaction id"
#>

Function Sign-PsArkMultiSigTransaction
{

}

##########################################################################################################################################################################################################
### Internal Functions
##########################################################################################################################################################################################################

Function Invoke-PsPsArkApiCall {

    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $True)]
        [System.String] $URI,
        
        [parameter(Mandatory = $True)]
        [ValidateSet('Get','Post','Put')]
        [System.String] $Method,
        
        [parameter(Mandatory = $False)]
        [System.Collections.Hashtable] $Body = @{}
        )
        
    if( $Method -eq 'Get' )
    {
        Write-Verbose "Invoke-PsArkApiCall [$Method] => $URI"
        $Private:WebRequest = Invoke-WebRequest -UseBasicParsing -Uri $URI -Method $Method
    }
    elseif( ( $Method -eq 'Post' ) -or ( $Method -eq 'Put' ) )
    {
        Write-Verbose "Invoke-PsArkApiCall [$Method] => $URI"
        $Private:WebRequest = Invoke-WebRequest -UseBasicParsing -Uri $URI -Method $Method -Body $Body
    }
    
    if( ( $WebRequest.StatusCode -eq 200 ) -and ( $WebRequest.StatusDescription -eq 'OK' ) )
    {
        $Private:Result = $WebRequest | ConvertFrom-Json
        if( $Result.success -eq $True ) { $Result }
        else { Write-Warning "Invoke-PsArkApiCall | success => false | error => $($Result.error)" }
    }
    else { Write-Warning "Invoke-PsArkApiCall | WebRequest returned Status '$($WebRequest.StatusCode) $($WebRequest.StatusDescription)'." }
}

##########################################################################################################################################################################################################
### Miscellaneous
##########################################################################################################################################################################################################

Function Show-PsArkAbout
{
	Write-Host ''
	ForEach( $Private:Line in Get-Content $( $PSScriptRoot + '\About.txt' ) ) 
	{
		Write-Host $Line -ForegroundColor Green
	}
	Write-Host ''
	Write-Host '    PsArk | PowerShell Module for Lisk API.     | https://github.com/Gr33nDrag0n69/PsArk/'
	Write-Host ''
}

##########################################################################################################################################################################################################
