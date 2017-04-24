<##########################################################################################################################################

Version :   0.1.0.0
Author  :   Gr33nDrag0n
History :   2017/04/24 - Release v0.1.0.0
            2017/04/20 - Creation of the module.

#### API Call Functions #############################################################

# Account #--------------------------------------------------------------------------

Get-PsArkAccount                                    v0.1.0.0 + Help		Public
Get-PsArkAccountBalance                             
Get-PsArkAccountPublicKey                           
Get-PsArkAccountVote                                
Get-PsArkAccountSecondSignature                     

New-PsArkAccount                                    
Open-PsArkAccount                                   
Add-PsArkAccountVote                                
Remove-PsArkAccountVote                             
Add-PsArkAccountSecondSignature                     

# Loader #---------------------------------------------------------------------------

Get-PsArkLoadingStatus                              v0.1.0.0 + Help		Public
Get-PsArkSyncStatus                                 v0.1.0.0 + Help		Public
Get-PsArkBlockReceiptStatus							v0.1.0.0 + Help		Public

# Transactions #---------------------------------------------------------------------

Get-PsArkTransaction                                
Get-PsArkTransactionList                            
Get-PsArkTransactionUnconfirmed                     
Get-PsArkTransactionUnconfirmedList                 

Send-PsArkTransaction                               

# Peers #----------------------------------------------------------------------------

Get-PsArkPeer                                       
Get-PsArkPeerList                                   
Get-PsArkPeerListVersion                            

# Blocks #---------------------------------------------------------------------------

Get-PsArkBlock                                      
Get-PsArkBlockList                                  
Get-PsArkBlockFee                                   
Get-PsArkBlockHeight                                
Get-PsArkBlockForged                                

# Delegates #------------------------------------------------------------------------

Get-PsArkDelegate                                   
Get-PsArkDelegateList                               
Get-PsArkDelegateVoterList                          

Enable-PsArkDelegate                                
Or
New-PsArkDelegate                                   

Enable-PsArkDelegateForging                         
Disable-PsArkDelegateForging                        

# Multi-Signature #------------------------------------------------------------------

Get-PsArkMultiSigPendingTransactionList             
Get-PsArkMultiSigAccountList                        

New-PsArkMultiSigAccount                            
Sign-PsArkMultiSigTransaction                       

#### Misc. Functions ################################################################

Invoke-PsPsArkApiCall                               v0.l.0.0			Private
Show-PsArkAbout                                     v0.l.0.0			Public
ConvertTo-PsArkBase64                               v0.l.0.0			Private
ConvertFrom-PsArkBase64                             v0.l.0.0			Private
Export-PsArkCsv                                     
Export-PsArkJson                                    

##########################################################################################################################################>

$Script:PsArk_Version = 'v0.1.0.0'


##########################################################################################################################################################################################################
### API Call: Accounts
##########################################################################################################################################################################################################

<#
.SYNOPSIS
    API Call: Get informations about an account from address.

.DESCRIPTION
    Return a custom object with following properties:

    address					: Address of account. [String]
    unconfirmedBalance		: Unconfirmed balance of account. [Int32]
    balance					: Balance of account. Integer,
    publicKey				: Public key of account. Hex,
    unconfirmedSignature	: If account enabled second signature, but it's still not confirmed. Boolean: true or false,
    secondSignature			: If account enabled second signature. Boolean: true or false,
    secondPublicKey			: Second signature public key. Hex

.PARAMETER URL
    Address of the target full node server processing the API query.

.PARAMETER Address
    Address of account.

.EXAMPLE
    Get-PsArkAccount -URL https://api.arknode.net/ -Address AHWHraW7xREemYCtxRx4YR2paiqGtgrX2M
#>

Function Get-PsArkAccount
{
    Param(
        [parameter(Mandatory = $True)]
        [System.String] $URL,

        [parameter(Mandatory = $True)]
        [System.String] $Address
        )

    $Private:Output = Invoke-PsPsArkApiCall -Method Get -URL $( $URL+'api/accounts?address='+$Address )
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
        [System.String] $URL='',

        [parameter(Mandatory = $True)]
        [System.String] $Address
        )

    if( $URL -eq '' ) { $URL = $Script:PsArk_URL }

    $Private:Output = Invoke-PsPsArkApiCall -Method Get -URL $( $URL+'api/accounts/getBalance/?address='+$Address )
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
        [System.String] $URL='',

        [parameter(Mandatory = $True)]
        [System.String] $Address
        )

    if( $URL -eq '' ) { $URL = $Script:PsArk_URL }

    $Private:Output = Invoke-PsPsArkApiCall -Method Get -URL $( $URL+'api/accounts/getPublicKey?address='+$Address )
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
        [System.String] $URL='',

        [parameter(Mandatory = $True)]
        [System.String] $Address
        )

    if( $URL -eq '' ) { $URL = $Script:PsArk_URL }

    $Private:Output = Invoke-PsPsArkApiCall -Method Get -URL $( $URL+'api/accounts/delegates?address='+$Address )
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

    $Private:Output = Invoke-PsPsArkApiCall -Method Post -URL $( $Script:PsArk_URL+'accounts/generatePublicKey' ) -Body @{secret=$Secret}
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

    $Private:Output = Invoke-PsPsArkApiCall -Method Post -URL $( $Script:PsArk_URL+'accounts/open' ) -Body @{secret=$Secret}
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

Function Add-PsArkAccountSecondSignature
{

}

##########################################################################################################################################################################################################
### API Call: Loader - Provides the synchronization and loading information of a client. These API calls will only work if the client is syncing or loading.
##########################################################################################################################################################################################################

<#
.SYNOPSIS
    API Call: Get the synchronisation status of the client.

.DESCRIPTION
    Return a custom object with following properties:

    Loaded      : Blockchain loaded? [Bool]
    Now         : Last block loaded during loading time. [Int]
    BlocksCount : Total blocks count in blockchain at loading time. [Int]

.PARAMETER URL
    Address of the target full node server processing the API query.

.EXAMPLE
    Get-PsArkLoadingStatus -URL https://api.arknode.net/
#>

Function Get-PsArkLoadingStatus
{
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $True)]
        [System.String] $URL
        )

    $Private:Output = Invoke-PsPsArkApiCall -Method Get -URL $( $URL+'api/loader/status' )
    if( $Output.Success -eq $True ) { $Output | Select-Object -Property @{Label="Loaded";Expression={$_.loaded}}, @{Label="Now";Expression={$_.now}}, @{Label="BlocksCount";Expression={$_.blocksCount}} }
}

##########################################################################################################################################################################################################

<#
.SYNOPSIS
    API Call: Get the synchronisation status of the client.

.DESCRIPTION
    Return a custom object with following properties:

    Syncing	: Sync. in progress? [Bool]
    Blocks	: Number of blocks remaining to sync. [Int]
    Height	: Total blocks in blockchain. [Int]
    BlockID	: Current height block ID [String]

.PARAMETER URL
    Address of the target full node server processing the API query.

.EXAMPLE
    Get-PsArkSyncStatus -URL https://api.arknode.net/
#>

Function Get-PsArkSyncStatus
{
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $True)]
        [System.String] $URL
        )

    $Private:Output = Invoke-PsPsArkApiCall -Method Get -URL $( $URL+'api/loader/status/sync' )
    if( $Output.Success -eq $True ) { $Output | Select-Object -Property @{Label="Syncing";Expression={$_.syncing}}, @{Label="Blocks";Expression={$_.blocks}}, @{Label="Height";Expression={$_.height}}, @{Label="BlockID";Expression={$_.id}} }
}

##########################################################################################################################################################################################################

<#
.SYNOPSIS
    API Call: Get the status of last received block.

.DESCRIPTION
    Returns True [Bool] if block was received in the past 120 seconds.

.PARAMETER URL
    Address of the target full node server processing the API query.

.EXAMPLE
    Get-PsArkBlockReceiptStatus -URL https://api.arknode.net/
#>

Function Get-PsArkBlockReceiptStatus
{
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $True)]
        [System.String] $URL
        )

    $Private:Output = Invoke-PsPsArkApiCall -Method Get -URL $( $URL+'api/loader/status/ping' )
    if( $Output.Success -ne $NULL ) { $Output.Success }
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
    $Private:Output = Invoke-PsPsArkApiCall -Method Get -URL $( $Script:PsArk_URL+'peers' )
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
### Miscellaneous
##########################################################################################################################################################################################################

Function Invoke-PsPsArkApiCall {

    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $True)]
        [System.String] $URL,

        [parameter(Mandatory = $True)]
        [ValidateSet('Get','Post','Put')]
        [System.String] $Method,

        [parameter(Mandatory = $False)]
        [System.Collections.Hashtable] $Body = @{}
        )

    if( $Method -eq 'Get' )
    {
        Write-Verbose "Invoke-PsArkApiCall [$Method] => $URL"
        Try { $Private:WebRequest = Invoke-WebRequest -UseBasicParsing -URI $URL -Method $Method }
		Catch { Write-Warning "Invoke-WebRequest FAILED on $URL !" }
    }
    elseif( ( $Method -eq 'Post' ) -or ( $Method -eq 'Put' ) )
    {
        Write-Verbose "Invoke-PsArkApiCall [$Method] => $URL"
        Try { $Private:WebRequest = Invoke-WebRequest -UseBasicParsing -URI $URL -Method $Method -Body $Body }
		Catch { Write-Warning "Invoke-WebRequest FAILED on $URL !" }
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

Function Show-PsArkAbout {

    #$Private:BannerData = Get-Content 'D:\GIT\PsArk\PsArk\BannerText.txt'
    #$Private:BannerData64 = ConvertTo-PsArkBase64 -Text $( Get-Content 'D:\GIT\PsArk\PsArk\BannerText.txt' | Out-String )
    #$BannerData64 | Out-File 'D:\GIT\PsArk\PsArk\BannerBase64.txt'

    $Private:BannerData = ConvertFrom-PsArkBase64 -EncodedText 'IAAkACwAIAAgACQALAAgACAAIAAgACAALAAiACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIABaACAAWgAgAFoAIAANAAoAIABgACIAcwBzAC4AJABzAHMALgAgAC4AcwAnACIAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIABaACAAWgAgAFoAIAANAAoAIAAuAHMAcwAkACQAJAAkACQAJAAkACQAJAAkAHMALAAiACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIABaACAAXwBfAF8AXwBfAF8AXwBfAF8AXwAgACAAIAAgACAAIAAgAFoAIAAgACAALwBcAFoAIAAgACAAIAAgACAAIAAgACAAXwBfACAAIAAgACAAIAAgACAAIAAgAA0ACgAgACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAYAAkACQAUwBzACIAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAFoAIABcAF8AXwBfAF8AXwBfACAAIAAgAFwAXwBfAF8AXwBfACAAWgAgACAALwAgACAAXABaAF8AXwBfAF8AXwBfAF8AfAAgACAAfAAgAF8AXwAgACAAIAAgAA0ACgAgACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJABvACQAJAAkACAAIAAgACAAIAAgACAALAAiACAAIAAgACAAIAAgACAAIAAgAFoAIAAgAHwAIAAgACAAIAAgAF8AXwBfAC8AIAAgAF8AXwBfAC8AWgAgAC8AIAAgACAAIABcAFoAXwAgACAAXwBfACAAXAAgACAAfAAvACAALwAgACAAIAANAAoAIAAkACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJABzACwAIAAgACwAcwAiACAAIAAgACAAIAAgACAAIABaACAAIAB8ACAAIAAgACAAfAAgACAAIABcAF8AXwBfACAAXAAgAFoALwAgACAALwBcACAAIABcAFoAIAAgAHwAIABcAC8AIAAgACAAIAA8ACAAIAAgAA0ACgAgACQAJAAkACQAJAAiACQAJAAkACQAJAAkACIAIgAiACIAJAAkACQAJAAkACQAIgAkACQAJAAkACQALAAnACAAIAAgACAAIAAgAFoAIAAgAHwAXwBfAF8AXwB8ACAAIAAvAF8AXwBfAF8AIAAgAFoALwAgACAALwBfAF8AXAAgACAAXABaAF8AfAAgACAAfABfAF8AfABfACAAXAAgAA0ACgAgACQAJAAkACQAJAAkAHMAIgAiACQAJAAkACQAcwBzAHMAcwBzAHMAIgAkACQAJAAkACQAJAAkACQAIgAnACAAIAAgACAAIAAgAFoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAXABaAC8AXwBfAC8AIAAgACAAIABcAF8AXwBcAFoAIAAgACAAIAAgACAAIAAgAFwALwANAAoAIAAkACQAJAAkACQAJwAgACAAIAAgACAAIAAgACAAIABgACIAIgAiAHMAcwAiACQAIgAkAHMAIgAiACcAIAAgACAAIAAgACAAIABaACAAWgAgAFoAIAANAAoAIAAkACQAJAAkACQALAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAYAAiACIAIgAiACIAJAAnACAAIAAgACAAIAAgACAAIABaACAAIAA9AD0APQBWAEUAUgBTAEkATwBOAD0APQA9ACAAYgB5ACAARwByADMAMwBuAEQAcgBhAGcAMABuACAAWgAgAFoAIAANAAoAIAAkACQAJAAkACQAJAAkAHMALAAuAC4ALgAiACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIABaACAAWgAgAFoAIAANAAoAIAAkACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJAAjACMAIwAjAHMALgAnACAAIAAgACAAIAAgACAAIAAgACAAIABaACAAIABEAG8AbgBhAHQAaQBvAG4AIABBAEgAVwBIAFIAQQBXADcAWABSAEUARQBNAFkAQwBUAFgAUgBYADQAWQBSADIAUABBAEkAUQBHAFQARwBSAFgAMgBNACAAWgAgAFoAIAANAAoA'
    #$BannerData | Out-File 'D:\GIT\PsArk\PsArk\BannerText.txt'

    $BannerData = $( $BannerData -Replace '===VERSION===',$Script:PsArk_Version ) -Split "`r`n"

    Write-Host ''
    Write-Host ''
    ForEach( $Private:Line in $BannerData )
    {
        $Private:Parts = $Line -Split 'Z'
        Write-Host $Parts[0] -ForegroundColor Green -NoNewLine
        Write-Host $Parts[1] -ForegroundColor White -NoNewLine
		Write-Host $Parts[2] -ForegroundColor Cyan -NoNewLine
        Write-Host $Parts[3] -ForegroundColor White
    }
    Write-Host ''
    Write-Host ''
}

##########################################################################################################################################################################################################

Function ConvertTo-PsArkBase64 {

    [CmdletBinding()]
    Param(
        [parameter( Mandatory=$True, Position=1 )]
        [System.String] $Text
        )

    $( [Convert]::ToBase64String( $( [System.Text.Encoding]::Unicode.GetBytes( $Text ) ) ) )
}

##########################################################################################################################################################################################################

Function ConvertFrom-PsArkBase64 {

    [CmdletBinding()]
    Param(
        [parameter( Mandatory=$True, Position=1 )]
        [System.String] $EncodedText
        )

    $( [System.Text.Encoding]::Unicode.GetString( [System.Convert]::FromBase64String( $EncodedText ) ) )
}

##########################################################################################################################################################################################################

# Export Public Functions

Export-ModuleMember -Function Get-PsArkAccount

# API - Loader
Export-ModuleMember -Function Get-PsArkLoadingStatus, Get-PsArkSyncStatus, Get-PsArkBlockReceiptStatus

# Miscellaneous
Export-ModuleMember -Function Show-PsArkAbout
