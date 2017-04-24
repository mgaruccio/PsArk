<##########################################################################################################################################

Version :   0.1.0.0
Author  :   Gr33nDrag0n
History :   2017/04/24 - Release v0.1.0.0
            2017/04/20 - Creation of the module.

Reference : https://github.com/LiskHQ/lisk-wiki/wiki/Lisk-API-Reference

#### API Call Functions #############################################################

# Account #--------------------------------------------------------------------------

Get-PsArkAccount                                    v0.1.0.0 + Help     Public
Get-PsArkAccountBalance
Get-PsArkAccountPublicKey
Get-PsArkAccountVote                                Struct              Public
Get-PsArkAccountSecondSignature

New-PsArkAccount
Open-PsArkAccount
Add-PsArkAccountVote
Remove-PsArkAccountVote
Add-PsArkAccountSecondSignature

# Loader #---------------------------------------------------------------------------

Get-PsArkLoadingStatus                              v0.1.0.0 + Help     Public
Get-PsArkSyncStatus                                 v0.1.0.0 + Help     Public
Get-PsArkBlockReceiptStatus                         v0.1.0.0 + Help     Public

# Transactions #---------------------------------------------------------------------

Get-PsArkTransaction
Get-PsArkTransactionList
Get-PsArkTransactionUnconfirmed
Get-PsArkTransactionUnconfirmedList

Send-PsArkTransaction

# Peers #----------------------------------------------------------------------------

Get-PsArkPeer                                       Struct              Public
Get-PsArkPeerList                                   Struct              Public
Get-PsArkPeerVersion                                Struct              Public

# Block / Blockchain #--------------------------------------------------------------

Get-PsArkBlockById                                  Struct              Public
Get-PsArkBlockList                                  Struct              Public
Get-PsArkBlockchainTransactionFee                   Struct              Public
Get-PsArkBlockchainAllFee                           Struct              Public
Get-PsArkBlockchainReward                           Struct              Public
Get-PsArkBlockchainSupply                           Struct              Public
Get-PsArkBlockchainHeight                           Struct              Public
Get-PsArkBlockchainStatus                           Struct              Public
Get-PsArkBlockchainNethash                          Struct              Public
Get-PsArkBlockchainMilestone                        Struct              Public

# Delegates #------------------------------------------------------------------------

Get-PsArkDelegateByPublicKey                        Struct              Public
Get-PsArkDelegateByUsername                         Struct              Public
Get-PsArkDelegateByTransactionId (Removed?)         Struct              Public
Get-PsArkDelegateList                               Struct              Public
Get-PsArkDelegateVoterList                          Struct              Public
Get-PsArkDelegateCount                              Struct              Public
Get-PsArkDelegateForgedByAccount                    Struct              Public
Get-PsArkDelegateNextForgers                        Struct              Public

New-PsArkDelegateAccount                            Struct              Public
Search-PsArkDelegate                                Struct              Public
Enable-PsArkDelegateForging                         Struct              Public
Disable-PsArkDelegateForging                        Struct              Public

# Signature #------------------------------------------------------------------------

Get-PsArkSignatureFee                               Struct              Public

Add-PsArkSecondSignature                            Struct              Public

# Multi-Signature #------------------------------------------------------------------

Get-PsArkMultiSigPendingTransactionList             Struct              Public
Get-PsArkMultiSigAccountList                        Struct              Public

New-PsArkMultiSigAccount                            Struct              Public
Approve-PsArkMultiSigTransaction                    Struct              Public

#### Misc. Functions ################################################################

Invoke-PsPsArkApiCall                               v0.l.0.0            Private
Show-PsArkAbout                                     v0.l.0.0            Public
ConvertTo-PsArkBase64                               v0.l.0.0            Private
ConvertFrom-PsArkBase64                             v0.l.0.0            Private
Export-PsArkCsv
Export-PsArkXml
Export-PsArkJson

##########################################################################################################################################>

$Script:PsArk_Version = 'v0.1.0.0'


##########################################################################################################################################################################################################
### API Call: Account
##########################################################################################################################################################################################################

<#
.SYNOPSIS
    API Call: Get informations about an account from address.

.DESCRIPTION
    Return a custom object with following properties:

    Address                    : Address of account. [String]
    PublicKey                  : Public key of account. [String]
    SecondPublicKey            : Second signature public key. [String]

    Balance                    : Balance of account. [Int]
    UnconfirmedBalance         : Unconfirmed balance of account. [Int]

    SecondSignature            : If second signature is enabled. [Bool]
    UnconfirmedSecondSignature : If second signature is enabled. (But it's still not confirmed.) [Bool]

    MultiSignatures            : (No infos available.) [Array]
    UnconfirmedMultiSignatures : (No infos available.) [Array]

.PARAMETER URL
    Address of the target full node server processing the API query.

.PARAMETER Address
    Address of account.

.EXAMPLE
    Get-PsArkAccount -URL https://api.arknode.net/ -Address AHWHraW7xREemYCtxRx4YR2paiqGtgrX2M
#>

Function Get-PsArkAccount {

    Param(
        [parameter(Mandatory = $True)]
        [System.String] $URL,

        [parameter(Mandatory = $True)]
        [System.String] $Address
        )

    $Private:Output = Invoke-PsPsArkApiCall -Method Get -URL $( $URL+'api/accounts?address='+$Address )
    if( $Output.success -eq $True )
    {
        $Output.account | Select-Object -Property  @{Label="Address";Expression={$_.address}}, `
                                                   @{Label="PublicKey";Expression={$_.publicKey}}, `
                                                   @{Label="SecondPublicKey";Expression={$_.secondPublicKey}}, `
                                                   @{Label="Balance";Expression={$_.balance}}, `
                                                   @{Label="UnconfirmedBalance";Expression={$_.unconfirmedBalance}}, `
                                                   @{Label="SecondSignature";Expression={$_.secondSignature}}, `
                                                   @{Label="UnconfirmedSecondSignature";Expression={$_.unconfirmedSignature}}, `
                                                   @{Label="MultiSignatures";Expression={$_.multisignatures}}, `
                                                   @{Label="UnconfirmedMultiSignatures";Expression={$_.u_multisignatures}}
    }
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

<#

Get votes of account

Get votes by account wallet address.

GET /api/accounts/delegates/?address=address

    address: Address of account. (String)

Response

{
  "success": true,
  "delegates": [
      "array of of delegates object (see above delegate object response)"
    ]
}

    Delegates Array includes: delegateId, address, publicKey, vote (# of votes), producedBlocks, missedBlocks, rate, productivity
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
    if( $Output.Success -eq $True )
    {
        $Output | Select-Object -Property  @{Label="Loaded";Expression={$_.loaded}}, `
                                           @{Label="Now";Expression={$_.now}}, `
                                           @{Label="BlocksCount";Expression={$_.blocksCount}}
    }
}

##########################################################################################################################################################################################################

<#
.SYNOPSIS
    API Call: Get the synchronisation status of the client.

.DESCRIPTION
    Return a custom object with following properties:

    Syncing : Sync. in progress? [Bool]
    Blocks  : Number of blocks remaining to sync. [Int]
    Height  : Total blocks in blockchain. [Int]
    BlockID : Current height block ID [String]

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
    if( $Output.Success -eq $True )
    {
        $Output | Select-Object -Property  @{Label="Syncing";Expression={$_.syncing}}, `
                                           @{Label="Blocks";Expression={$_.blocks}}, `
                                           @{Label="Height";Expression={$_.height}}, `
                                           @{Label="BlockID";Expression={$_.id}}
    }
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

Gets peer by IP address and port

GET /api/peers/get?ip=ip&port=port

    ip: Ip of peer. (String)
    port: Port of peer. (Integer)

Response

{
  "success": true,
  "peer": {
        "ip":"Requested ip. String",
        "port":"Requested port. Integer",
        "state":"1 - disconnected. 2 - connected. 0 - banned. Integer",
        "os":"Operating system. String",
        "version":"Lisk client version. String",
        "broadhash":"Peer block propagation efficiency and reliability. String",
        "height":"Blockchain height. Integer"
  }
}
#>

Function Get-PsArkPeer {

    $Private:Output = Invoke-PsPsArkApiCall -Method Get -URL $( $Script:PsArk_URL+'peers' )
    if( $Output.success -eq $True ) { $Output.peers }
}

##########################################################################################################################################################################################################

<#
Get peers list

Gets list of peers from provided filter parameters.

GET /api/peers?state=state&os=os&version=version&limit=limit&offset=offset&orderBy=orderBy

    state: State of peer. 1 - disconnected. 2 - connected. 0 - banned. (Integer)
    os: OS of peer. (String)
    version: Version of peer. (String)
    limit: Limit to show. Max limit is 100. (Integer)
    offset: Offset to load. (Integer)
    orderBy: Name of column to order. After column name must go "desc" or "acs" to choose order type. (String)

All parameters joins by "OR".

Example:
/api/peers?state=1&version=0.3.2 looks like: state=1 OR version=0.3.2

Response

{
  "success": true,
  "peers": [
    "List of peers as objects (see below the peer object response)"
  ]
}
#>

Function Get-PsArkPeerList {

    # TODO
}

##########################################################################################################################################################################################################

<#
Get peer version, build time

Gets a list peer versions and build times

GET /api/peers/version

Response

{
  "success": true,
  "version": "Version of Lisk. String",
  "build": "Time of build. String"
}
#>

Function Get-PsArkPeerVersion {

    # TODO
}

##########################################################################################################################################################################################################
### API Call: Block / Blockchain
##########################################################################################################################################################################################################

<#
Get block

Gets block by provided id.

GET /api/blocks/get?id=id

    id: Id of block.

Response

{
    "success": true,
    "block": {
        "id": "Id of block. String",
        "version": "Version of block. Integer",
        "timestamp": "Timestamp of block. Integer",
        "height": "Height of block. Integer",
        "previousBlock": "Previous block id. String",
        "numberOfTransactions": "Number of transactions. Integer",
        "totalAmount": "Total amount of block. Integer",
        "totalFee": "Total fee of block. Integer",
        "reward": "Reward block. Integer",
        "payloadLength": "Payload length of block. Integer",
        "payloadHash": "Payload hash of block. Integer",
        "generatorPublicKey": "Generator public key. Hex",
        "generatorId": "Generator id. String.",
        "blockSignature": "Block signature. Hex",
        "confirmations": "Block confirmations. Integer",
        "totalForged": "Total block forged. Integer"
    }
}
#>

Function Get-PsArkBlockById {

    # TODO
}

##########################################################################################################################################################################################################

<#
Get blocks

Gets all blocks by provided filter(s).

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

{
  "success": true,
  "blocks": [
    "array of blocks (see below block object response)"
  ]
}
#>

Function Get-PsArkBlockList {

    # TODO
}

##########################################################################################################################################################################################################

<#
Get blockchain fee

Get transaction fee for sending "normal" transactions.

GET /api/blocks/getFee

Response

{
  "success": true,
  "fee": Integer
}
#>

Function Get-PsArkBlockchainTransactionFee {

    # TODO
}

##########################################################################################################################################################################################################

<#
Get blockchain fees schedule

Get transaction fee for all types of transactions.

GET /api/blocks/getFees

Response

{
  "success": true,
  "fees":{
    "send": Integer,
    "vote": Integer,
    "secondsignature": Integer,
    "delegate": Integer,
    "multisignature": Integer,
    "dapp": Integer
  }
}
#>

Function Get-PsArkBlockchainAllFee {

    # TODO
}

##########################################################################################################################################################################################################

<#
Get blockchain reward schedule

Gets the forging reward for blocks.

GET /api/blocks/getReward

Response

{
  "success": true,
  "reward": Integer
}
#>

Function Get-PsArkBlockchainReward {

    # TODO
}

##########################################################################################################################################################################################################

<#
Get supply of available Lisk

Gets the total amount of Lisk in circulation

GET /api/blocks/getSupply

Response

{
  "success": true,
  "supply": Integer
}
#>

Function Get-PsArkBlockchainSupply {

    # TODO
}

##########################################################################################################################################################################################################

<#

Get blockchain height

Gets the blockchain height of the client.

GET /api/blocks/getHeight

Response

{
  "success": true,
  "height": "Height of blockchain. Integer"
}
#>

Function Get-PsArkBlockchainHeight {

    # TODO
}

##########################################################################################################################################################################################################

<#
Gets status of height, fee, milestone, blockreward and supply

Gets status of height, fee, milestone, blockreward and supply

GET /api/blocks/getStatus

Response

{
  "success": true,
  "height": Integer
  "fee": Integer
  "milestone": Integer
  "reward": Integer
  "supply": Integer
}
#>

Function Get-PsArkBlockchainStatus {

    # TODO
}

##########################################################################################################################################################################################################

<#
Get blockchain nethash

Gets the nethash of the blockchain on a client.

GET /api/blocks/getNethash

Response

{
  "success": true,
  "nethash": "Nethash of the Blockchain. String"
}
#>

Function Get-PsArkBlockchainNethash {

    # TODO
}

##########################################################################################################################################################################################################

<#
Get blockchain milestone

Gets the milestone of the blockchain on a client.

GET /api/blocks/getMilestone

Response

{
  "success": true,
  "milestone": Integer
}
#>

Function Get-PsArkBlockchainMilestone {

    # TODO
}


##########################################################################################################################################################################################################
### API Call: Delegates
##########################################################################################################################################################################################################

<#
Get delegate

Gets delegate by public key.

GET /api/delegates/get?publicKey=publicKey

    publicKey: Public key of delegate account (String)

Response

{
    "success": true,
    "delegate": {
        "username": "Username. String",
        "address": "Address. String",
        "publicKey": "Public key. String",
        "vote": "Total votes. Integer",
        "producedblocks": "Produced blocks. Integer",
        "missedblocks": "Missed blocks. Integer",
        "rate": "Ranking. Integer",
        "approval": "Approval percentage. Float",
        "productivity": "Productivity percentage. Float"
    }
}
#>

Function Get-PsArkDelegateByPublicKey {

    # TODO
}

##########################################################################################################################################################################################################

<#
Get delegate

Gets delegate by username.

GET /api/delegates/get?username=username

    username: Username of delegate account (String)

Response

{
    "success": true,
    "delegate": {
        "username": "Username. String",
        "address": "Address. String",
        "publicKey": "Public key. String",
        "vote": "Total votes. Integer",
        "producedblocks": "Produced blocks. Integer",
        "missedblocks": "Missed blocks. Integer",
        "rate": "Ranking. Integer",
        "approval": "Approval percentage. Float",
        "productivity": "Productivity percentage. Float"
    }
}
#>

Function Get-PsArkDelegateByUsername {

    # TODO
}

##########################################################################################################################################################################################################

<#
==> REMOVED ?

Get delegate by transaction id.

GET /api/delegates/get?id=transactionId

transactionId: Id of transaction where delegated was putted. (String)

Response
    "delegate":
        "username": "username of delegate",
        "transactionId": "transaction id",
        "votes": "amount of stake voted for this delegate"
#>

Function Get-PsArkDelegateByTransactionId {

    # TODO
}

##########################################################################################################################################################################################################

<#
Get delegates list

Gets list of delegates by provided filter.

GET /api/delegates?limit=limit&offset=offset&orderBy=orderBy

    limit: Limit to show. Integer. Maximum is 100. (Integer)
    offset: Offset (Integer)
    orderBy: Order by field (String)

Response

{
  "success": true,
  "delegates": "delegates objects array"
}

Delegates Array includes: delegateId, address, publicKey, vote (# of votes), producedBlocks, missedBlocks, rate, productivity
#>

Function Get-PsArkDelegateList {

    # TODO
}

##########################################################################################################################################################################################################

<#
Get voters

Get voters of delegate.

GET /api/delegates/voters?publicKey=publicKey

publicKey: Public key of delegate. (String)

Response

  "accounts": [
    {
      username: "Voter username. String",
      address: "Voter address. String",
      publicKey: "Voter public key. String",
      balance: "Voter balance. String"
    }
  ]
#>

Function Get-PsArkDelegateVoterList {

    # TODO
}

##########################################################################################################################################################################################################

<#
Get delegates count

Get total count of registered delegates.

GET /api/delegates/count

Response

{
  "success": true,
  "count": 101
}
#>

Function Get-PsArkDelegateCount {

    # TODO
}

##########################################################################################################################################################################################################

<#
Get forged by account

Get amount of Lisk forged by an account.

GET /api/delegates/forging/getForgedByAccount?generatorPublicKey=generatorPublicKey

Required

    generatorPublicKey: generator id of block in hex. (String)

Optional

    start: Sets the start time of the search - timestamp UNIX time. (String)
    end: Sets the endtime of the search - timestamp UNIX time. (String)

Response

{
  "success": true,
  "fees": "Forged amount. Integer",
  "rewards":"Forged amount. Integer",
  "forged":"Forged amount. Integer"
}
#>

Function Get-PsArkDelegateForgedByAccount {

    # TODO
}

##########################################################################################################################################################################################################

<#
Get next forgers

Get next delegate lining up to forge.

GET /api/delegates/getNextForgers?limit=limit

    limit: limits the amount of delegates returned, default 10, max 101 (Integer)

Response

{
  "success": true,
  "currentBlock": "Current block based on height. Integer",
  "currentSlot": "Current slot based on time. Integer",
  "delegates": [
          "array of publicKeys. Strings"
        ]
}

#>

Function Get-PsArkDelegateNextForgers {

    # TODO
}

##########################################################################################################################################################################################################

<#
Enable delegate on account

WARNING: This operation have a COST!

Puts request to create a delegate.

PUT /api/delegates

Request

{
  "secret": "Secret key of account",
  "secondSecret": "Second secret of account",
  "username": "Username of delegate. String from 1 to 20 characters."
}

Response

{
   "success":true,
   "transaction":{
      "type": "Type of transaction. Integer",
      "amount": "Amount. Integer",
      "senderPublicKey": "Sender public key. String",
      "requesterPublicKey": "Requester public key. String",
      "timestamp": "Time. Integer",
      "asset":{
         "delegate":{
            "username": "Delegate username. String",
            "publicKey": "Delegate public key. String"
         }
      },
      "recipientId": "Recipient address. String",
      "signature": "Signature. String",
      "signSignature": "Sign signature. String",
      "id": "Tx ID. String",
      "fee": "Fee. Integer",
      "senderId": "Sender address. String",
      "relays": "Propagation. Integer",
      "receivedAt": "Time. String"
   }
}
#>

Function New-PsArkDelegateAccount {

    # TODO
}

##########################################################################################################################################################################################################

<#
Search for delegates

Search for Delegates by "fuzzy" username.

GET /api/delegates/search?q=username&orderBy=producedblocks:desc

    q: Search criteria. (String)
    orderBy: Order results by ascending or descending property. Valid sort fields are: username:asc, username:desc, address:asc, address:desc, publicKey:asc, publicKey:desc, vote:asc, vote:desc, missedblocks:asc, missedblocks:desc, producedblocks:asc, producedblocks:desc

Response

{
  "success": true,
  "delegates": [
    "array of delegates"
  ]
}
#>

Function Search-PsArkDelegate {

    # TODO
}

##########################################################################################################################################################################################################

<#
Enable forging on delegate

Enables forging for a delegate on the client node.

POST /api/delegates/forging/enable

Request
  "secret": "secret key of delegate account"

Response
  "address": "address"
#>

Function Enable-PsArkDelegateForging {

    # TODO
}

##########################################################################################################################################################################################################

<#
Disable forging on delegate

Disables forging for a delegate on the client node.

POST /api/delegates/forging/disable

Request
  "secret": "secret key of delegate account"

Response
  "address": "address"
#>

Function Disable-PsArkDelegateForging {

    # TODO
}


##########################################################################################################################################################################################################
### API Call: Signatures
##########################################################################################################################################################################################################

<#
Get Signature Fees

Gets the second signature status of an account.

GET /api/signatures/fee

Response

"fee" : Integer
#>

Function Get-PsArkSignatureFee {

    # TODO
}

##########################################################################################################################################################################################################

<#
Add second signature

Add a second signature to an account.

PUT /api/signatures

Request

{
  "secret": "secret key of account",
  "secondsecret": "second secret key of account",
  "publicKey": "optional, to verify valid secret key and account"
}

Response

{
   "success": true,
   "transaction": {
      "type": "Type of transaction. Integer",
      "amount": "Amount. Integer",
      "senderPublicKey": "Sender public key. String",
      "requesterPublicKey": "Requester public key. String",
      "timestamp": Integer,
      "asset":{
         "signature":{
            "publicKey": "Public key. String"
         }
      },
      "recipientId": "Recipient address. String",
      "signature": "Signature. String",
      "id": "Tx ID. String",
      "fee": "Fee Integer",
      "senderId": "Sender address. String",
      "relays": "Propagation. Integer",
      "receivedAt": "Time. String"
   }
}
#>

Function Add-PsArkSecondSignature {

    # TODO
}


##########################################################################################################################################################################################################
### API Call: Multi-Signature
##########################################################################################################################################################################################################

<#
Get pending multi-signature transactions

Returns a list of multi-signature transactions that waiting for signature by publicKey.

GET /api/multisignatures/pending?publicKey=publicKey

publicKey: Public key of account (String)

    Response
    {
      "success": true,
      "transactions": [
        {
          "max": "Max. Integer",
          "min": "Min. Integer",
          "lifetime": "Lifetime. Integer",
          "signed": true,
          "transaction": {
            "type": "Type of transaction. Integer",
            "amount": "Amount. Integer",
            "senderPublicKey": "Sender public key of transaction. Hex",
            "requesterPublicKey": "Requester public key. String",
            "timestamp": "Timestamp. Integer",
            "asset": {
              "multisignature": {
                "min": "Min signatures needed for valid tx. Integer",
                "keysgroup": [
                  "+Multisig public key member. String"
                ],
                "lifetime": "Lifetime. Integer",
              }
            },
            "recipientId": "Recipient address. String",
            "signature": "Signature. String",
            "signSignature": "Sign signature. String",
            "id": "Tx ID",
            "fee": "Fee. Integer",
            "senderId": "Sender address. String",
            "relays": "Propagation. Integer",
            "receivedAt": Time. String",
            "signatures": [
              "array of signatures"
            ],
            "ready": false
          }
        }
      ]
    }
#>

Function Get-PsArkMultiSigPendingTransactionList {

    # TODO
}

##########################################################################################################################################################################################################

<#
Get multi-signature accounts list.

Gets a list of accounts that belong to a multi-signature account.

GET /api/multisignatures/accounts?publicKey=publicKey

publicKey: Public key of multi-signature account (String)

Response
  "accounts": "array of accounts"
"accounts": [
    {
      "address": "Multisig account. String",
      "balance": "Multisig account balance. String",
      "multisignatures": [
        "Multisig public key member. String"
      ],
      "multimin": "Min N of sign for a valid tx. Integer",
      "multilifetime": "Lifetime. Integer",
      multisigaccounts": [
        {
          "address": "Multisig address member. String",
          "publicKey": "Multisig public key member. String",
          "balance": "Multisig balance member. String"
        }
      ]
    }
  ]
#>

Function Get-PsArkMultiSigAccountList {

    # TODO
}

##########################################################################################################################################################################################################

<#
Create multi-signature account

PUT /api/multisignatures

Request
{
    "secret": "your secret. string. required.",
    "secondSecret": "your second secret of the account. optional"
    "lifetime": "request lifetime in hours (1-72). required.",
    "min": "minimum signatures needed to approve a tx or a change (1-16). integer. required",
    "keysgroup": [array of public keys strings]. add '+' before publicKey to add an account. required. immutable.
}
Response
  "transactionId": "transaction id"
#>

Function New-PsArkMultiSigAccount {

    # TODO
}

##########################################################################################################################################################################################################

<#
Signs a transaction that is awaiting signature.

POST /api/multisignatures/sign

Request
  "secret": "your secret. string. required.",
  "publicKey": "public key of your account. string. optional.",
  "transactionId": "id of transaction to sign"

Response
  "transactionId": "transaction id"

  Lisk ONLY ?
#>

Function Approve-PsArkMultiSigTransaction {

    # TODO
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

    $Private:BannerData = ConvertFrom-PsArkBase64 -EncodedText 'IAAkACwAIAAgACQALAAgACAAIAAgACAALAAiACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIABaACAAWgAgAFoAIAANAAoAIABgACIAcwBzAC4AJABzAHMALgAgAC4AcwAnACIAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIABaACAAWgAgAFoAIAANAAoAIAAuAHMAcwAkACQAJAAkACQAJAAkACQAJAAkAHMALAAiACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIABaACAAXwBfAF8AXwBfAF8AXwBfAF8AXwAgACAAIAAgACAAIAAgAFoAIAAgACAALwBcAFoAIAAgACAAIAAgACAAIAAgACAAXwBfACAAIAAgACAAIAAgACAAIAAgAA0ACgAgACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAYAAkACQAUwBzACIAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAFoAIABcAF8AXwBfAF8AXwBfACAAIAAgAFwAXwBfAF8AXwBfACAAWgAgACAALwAgACAAXABaAF8AXwBfAF8AXwBfAF8AfAAgACAAfAAgAF8AXwAgACAAIAAgAA0ACgAgACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJABvACQAJAAkACAAIAAgACAAIAAgACAALAAiACAAIAAgACAAIAAgAFoAIAAgAHwAIAAgACAAIAAgAF8AXwBfAC8AIAAgAF8AXwBfAC8AWgAgAC8AIAAgACAAIABcAFoAXwAgACAAXwBfACAAXAAgACAAfAAvACAALwAgACAAIAANAAoAIAAkACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJABzACwAIAAgACwAcwAiACAAIAAgACAAIABaACAAIAB8ACAAIAAgACAAfAAgACAAIABcAF8AXwBfACAAXAAgAFoALwAgACAALwBcACAAIABcAFoAIAAgAHwAIABcAC8AIAAgACAAIAA8ACAAIAAgAA0ACgAgACQAJAAkACQAJAAiACQAJAAkACQAJAAkACIAIgAiACIAJAAkACQAJAAkACQAIgAkACQAJAAkACQALAAnACAAIAAgAFoAIAAgAHwAXwBfAF8AXwB8ACAAIAAvAF8AXwBfAF8AIAAgAFoALwAgACAALwBfAF8AXAAgACAAXABaAF8AfAAgACAAfABfAF8AfABfACAAXAAgAA0ACgAgACQAJAAkACQAJAAkAHMAIgAiACQAJAAkACQAcwBzAHMAcwBzAHMAIgAkACQAJAAkACQAJAAkACQAIgAnACAAIAAgAFoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAXABaAC8AXwBfAC8AIAAgACAAIABcAF8AXwBcAFoAIAAgACAAIAAgACAAIAAgAFwALwANAAoAIAAkACQAJAAkACQAJwAgACAAIAAgACAAIAAgACAAIABgACIAIgAiAHMAcwAiACQAIgAkAHMAIgAiACcAIAAgACAAIABaACAAWgAgAFoAIAANAAoAIAAkACQAJAAkACQALAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAYAAiACIAIgAiACIAJAAnACAAIAAgACAAIABaACAAIAA9AD0APQBWAEUAUgBTAEkATwBOAD0APQA9ACAAYgB5ACAARwByADMAMwBuAEQAcgBhAGcAMABuACAAWgAgAFoAIAANAAoAIAAkACQAJAAkACQAJAAkAHMALAAuAC4ALgAiACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIABaACAAWgAgAFoAIAANAAoAIAAkACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJAAjACMAIwAjAHMALgAnACAAIAAgACAAIAAgACAAIABaACAAIABEAG8AbgBhAHQAaQBvAG4AIABBAEgAVwBIAHIAYQBXADcAeABSAEUAZQBtAFkAQwB0AHgAUgB4ADQAWQBSADIAcABhAGkAcQBHAHQAZwByAFgAMgBNACAAWgAgAFoAIAANAAoA'
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


##### Export Public Functions #####

#### API ############################################################################

# Account #--------------------------------------------------------------------------

Export-ModuleMember -Function Get-PsArkAccount
#Export-ModuleMember -Function Get-PsArkAccountBalance
#Export-ModuleMember -Function Get-PsArkAccountPublicKey
#Export-ModuleMember -Function Get-PsArkAccountVote
#Export-ModuleMember -Function Get-PsArkAccountSecondSignature

#Export-ModuleMember -Function New-PsArkAccount
#Export-ModuleMember -Function Open-PsArkAccount
#Export-ModuleMember -Function Add-PsArkAccountVote
#Export-ModuleMember -Function Remove-PsArkAccountVote
#Export-ModuleMember -Function Add-PsArkAccountSecondSignature

# Loader #---------------------------------------------------------------------------

Export-ModuleMember -Function Get-PsArkLoadingStatus
Export-ModuleMember -Function Get-PsArkSyncStatus
Export-ModuleMember -Function Get-PsArkBlockReceiptStatus

# Transactions #---------------------------------------------------------------------

#Export-ModuleMember -Function Get-PsArkTransaction
#Export-ModuleMember -Function Get-PsArkTransactionList
#Export-ModuleMember -Function Get-PsArkTransactionUnconfirmed
#Export-ModuleMember -Function Get-PsArkTransactionUnconfirmedList
#Export-ModuleMember -Function Send-PsArkTransaction

# Peers #----------------------------------------------------------------------------

#Export-ModuleMember -Function Get-PsArkPeer
#Export-ModuleMember -Function Get-PsArkPeerList
#Export-ModuleMember -Function Get-PsArkPeerVersion

# Block / Blockchain #--------------------------------------------------------------

#Export-ModuleMember -Function Get-PsArkBlockById
#Export-ModuleMember -Function Get-PsArkBlockList
#Export-ModuleMember -Function Get-PsArkBlockchainTransactionFee
#Export-ModuleMember -Function Get-PsArkBlockchainAllFee
#Export-ModuleMember -Function Get-PsArkBlockchainReward
#Export-ModuleMember -Function Get-PsArkBlockchainSupply
#Export-ModuleMember -Function Get-PsArkBlockchainHeight
#Export-ModuleMember -Function Get-PsArkBlockchainStatus
#Export-ModuleMember -Function Get-PsArkBlockchainNethash
#Export-ModuleMember -Function Get-PsArkBlockchainMilestone

# Delegate #-------------------------------------------------------------------------

#Export-ModuleMember -Function Get-PsArkDelegateByPublicKey
#Export-ModuleMember -Function Get-PsArkDelegateByUsername
#Export-ModuleMember -Function Get-PsArkDelegateByTransactionId
#Export-ModuleMember -Function Get-PsArkDelegateList
#Export-ModuleMember -Function Get-PsArkDelegateVoterList
#Export-ModuleMember -Function Get-PsArkDelegateCount
#Export-ModuleMember -Function Get-PsArkDelegateForgedByAccount
#Export-ModuleMember -Function Get-PsArkDelegateNextForgers

#Export-ModuleMember -Function New-PsArkDelegateAccount
#Export-ModuleMember -Function Search-PsArkDelegate
#Export-ModuleMember -Function Enable-PsArkDelegateForging
#Export-ModuleMember -Function Disable-PsArkDelegateForging

# Signature #------------------------------------------------------------------------

#Export-ModuleMember -Function Get-PsArkSignatureFee
#Export-ModuleMember -Function Add-PsArkSecondSignature

# Multi-Signature #------------------------------------------------------------------

#Export-ModuleMember -Function Get-PsArkMultiSigPendingTransactionList
#Export-ModuleMember -Function Get-PsArkMultiSigAccountList

#Export-ModuleMember -Function New-PsArkMultiSigAccount
#Export-ModuleMember -Function Approve-PsArkMultiSigTransaction


#### Misc. Functions ################################################################

Export-ModuleMember -Function Show-PsArkAbout
