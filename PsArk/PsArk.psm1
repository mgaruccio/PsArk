<##########################################################################################################################################

Version :   0.2.0.0
Author  :   Gr33nDrag0n
History :   2017/05/14 - Release v0.1.0.0
            2017/04/20 - Creation of the module.

Reference : https://github.com/LiskHQ/lisk-swiki/wiki/Lisk-API-Reference

# Account #--------------------------------------------------------------------------

Get-PsArkAccount                                    Code + Help         Public
Get-PsArkAccountBalance                             Code + Help         Public
Get-PsArkAccountPublicKey                           Code + Help         Public
Get-PsArkAccountVoteList                            Code + Help         Public
Get-PsArkAccountSecondSignature (Deprecated !?)     Struct              Hidden

New-PsArkAccount                                    Struct              Hidden
Open-PsArkAccount                                   Struct              Hidden
Add-PsArkAccountVote                                Struct              Hidden
Remove-PsArkAccountVote                             Struct              Hidden
Add-PsArkAccountSecondSignature                     Struct              Hidden

# Loader #---------------------------------------------------------------------------

Get-PsArkLoadingStatus                              Code + Help         Public
Get-PsArkSyncStatus                                 Code + Help         Public
Get-PsArkBlockReceiptStatus                         Code + Help         Public

# Transactions #---------------------------------------------------------------------

Get-PsArkTransactionById                            Code + Help         Public
Get-PsArkTransactionList                            Code + Help         Public
Get-PsArkUnconfirmedTransactionById                 Code + Help         Public
Get-PsArkUnconfirmedTransactionList                 Struct              Hidden
Get-PsArkQueuedTransactionById                      Struct              Hidden
Get-PsArkQueuedTransactionList                      Struct              Hidden

Create-PsArkTransaction                             Code + Help         Public
Send-PsArkTransaction                               Struct              Hidden

# Peers #----------------------------------------------------------------------------

Get-PsArkPeer                                       Code + Help         Public
Get-PsArkPeerList                                   Code + Help         Public
Get-PsArkPeerVersion                                Code                Disabled

# Block / Blockchain #--------------------------------------------------------------

Get-PsArkBlockByID                                  Code + Help         Public
Get-PsArkBlockByHeight                              Code + Help         Public
Get-PsArkBlockByPreviousBlockID                     Code + Help         Public


Get-PsArkBlockList                                  Struct              Hidden
Get-PsArkBlockchainTransactionFee                   Struct              Hidden
Get-PsArkBlockchainSignatureFee                     Struct              Hidden
Get-PsArkBlockchainAllFee                           Struct              Hidden
Get-PsArkBlockchainReward                           Struct              Hidden
Get-PsArkBlockchainSupply                           Struct              Hidden
Get-PsArkBlockchainHeight                           Struct              Hidden
Get-PsArkBlockchainStatus                           Struct              Hidden
Get-PsArkBlockchainNethash                          Struct              Hidden
Get-PsArkBlockchainMilestone                        Struct              Hidden

# Delegates #------------------------------------------------------------------------

Get-PsArkDelegateByPublicKey                        Struct              Hidden
Get-PsArkDelegateByUsername                         Struct              Hidden
Get-PsArkDelegateByTransactionId (Removed?)         Struct              Hidden
Get-PsArkDelegateList                               Struct              Hidden
Get-PsArkDelegateVoterList                          Struct              Hidden
Get-PsArkDelegateCount                              Struct              Hidden
Get-PsArkDelegateForgedByAccount                    Struct              Hidden
Get-PsArkDelegateForgingStatus                      Struct              Hidden
Get-PsArkDelegateNextForgers                        Struct              Hidden

New-PsArkDelegateAccount                            Struct              Hidden
Search-PsArkDelegate                                Struct              Hidden
Enable-PsArkDelegateForging                         Struct              Hidden
Disable-PsArkDelegateForging                        Struct              Hidden

# Multi-Signature #------------------------------------------------------------------

Get-PsArkMultiSigPendingTransactionList             Struct              Hidden
Get-PsArkMultiSigAccountList                        Struct              Hidden

New-PsArkMultiSigAccount                            Struct              Hidden
Approve-PsArkMultiSigTransaction                    Struct              Hidden

#### Misc. Functions ################################################################

Invoke-PsArkApiCall                                 Code                Private
Show-PsArkAbout                                     Code                Public
ConvertTo-PsArkBase64                               Code                Private
ConvertFrom-PsArkBase64                             Code                Private
Export-PsArkCsv
Export-PsArkXml
Export-PsArkJson

##########################################################################################################################################>

$Script:PsArk_Version = "1.1.1"
$Script:Network_Data = Get-Content "$($PsScriptroot)\Resources\NetWorkInfo.json" | ConvertFrom-Json
Import-Module "$($PsScriptroot)\Resources\nbitcoin.dll"


##########################################################################################################################################################################################################
### API Call: Account
##########################################################################################################################################################################################################

<#
.SYNOPSIS
    Get informations about an account from address.

.DESCRIPTION
    Return a custom object with following properties:

        Address                    : Address of account. [String]

        PublicKey                  : Public key of account. [String]

        SecondPublicKey            : Second signature public key. [String]

        Balance                    : Balance of account in 'satoshi'. [String]
                                 1.1 Ark = 110000000 Value

        BalanceFloat               : Balance of account in 'float'. [Double]
                                 1.1 Ark = 1.1 Value

        UnconfirmedBalance         : Unconfirmed Balance of account in 'satoshi'. [String]
                                 1.1 Ark = 110000000 Value

        UnconfirmedBalanceFloat    : Unconfirmed Balance of account in 'float'. [Double]
                                 1.1 Ark = 1.1 Value

        SecondSignature            : If second signature is enabled. [Boolean]

        UnconfirmedSecondSignature : If second signature is enabled. (But it's still not confirmed.) [Boolean]

        MultiSignatures            : (No infos available.) [Array]

        UnconfirmedMultiSignatures : (No infos available.) [Array]

.PARAMETER URL
    Address of the target full node server processing the API query.

.PARAMETER Address
    Address of account.

.EXAMPLE
    $Account = Get-PsArkAccount -URL https://api.arknode.net/ -Address AHWHraW7xREemYCtxRx4YR2paiqGtgrX2M
#>

Function Get-PsArkAccount {
    
    Param(
        [parameter(Mandatory = $True)]
        [ValidateSet("DevNet","MainNet")]
        [System.String] $Network,

        [parameter(Mandatory = $True)]
        [System.String] $Address
        )

    $Peer = Find-PsArkPeer -Network $Network
    $URL = "$($Peer.IP):$($Peer.Port)"

    $Private:Output = Invoke-PsArkApiCall -Method Get -URL $( $URL+'/api/accounts?address='+$Address )
    if( $Output.success -eq $True )
    {
        $Output.account | Select-Object -Property  @{Label="Address";Expression={$_.address}}, `
                                                    @{Label="PublicKey";Expression={$_.publicKey}}, `
                                                    @{Label="SecondPublicKey";Expression={$_.secondPublicKey}}, `
                                                    @{Label="Balance";Expression={$_.balance}}, `
                                                    @{Label="BalanceFloat";Expression={$_.balance/100000000}}, `
                                                    @{Label="UnconfirmedBalance";Expression={$_.unconfirmedBalance}}, `
                                                    @{Label="UnconfirmedBalanceFloat";Expression={$_.unconfirmedBalance/100000000}}, `
                                                    @{Label="SecondSignature";Expression={[bool] $_.secondSignature}}, `
                                                    @{Label="UnconfirmedSecondSignature";Expression={[bool] $_.unconfirmedSignature}}, `
                                                    @{Label="MultiSignatures";Expression={$_.multisignatures}}, `
                                                    @{Label="UnconfirmedMultiSignatures";Expression={$_.u_multisignatures}}
    }
}

##########################################################################################################################################################################################################

<#
.SYNOPSIS
    Get the balance of an account.

.DESCRIPTION
    Return a custom object with following properties:

        Address                    : Address of account. [String]

        Balance                    : Balance of account in 'satoshi'. [String]
                                 1.1 Ark = 110000000 Value

        BalanceFloat               : Balance of account in 'float'. [Double]
                                 1.1 Ark = 1.1 Value

        UnconfirmedBalance         : Unconfirmed Balance of account in 'satoshi'. [String]
                                 1.1 Ark = 110000000 Value

        UnconfirmedBalanceFloat    : Unconfirmed Balance of account in 'float'. [Double]
                                 1.1 Ark = 1.1 Value

.PARAMETER URL
    Address of the target full node server processing the API query.

.PARAMETER Address
    Address of account.

.EXAMPLE
    $AccountBalance = Get-PsArkAccountBalance -URL https://api.arknode.net/ -Address AHWHraW7xREemYCtxRx4YR2paiqGtgrX2M

#>

Function Get-PsArkAccountBalance {

    Param(
        [parameter(Mandatory = $True)]
        [ValidateSet("DevNet","MainNet")]
        [System.String] $Network,

        [parameter(Mandatory = $True)]
        [System.String] $Address
        )

    $Peer = Find-PsArkPeer -Network $Network
    $URL = "$($Peer.IP):$($Peer.Port)"

    $Private:Output = Invoke-PsArkApiCall -Method Get -URL $( $URL+'/api/accounts/getBalance/?address='+$Address )
    if( $Output.success -eq $True )
    {
        $Output | Select-Object -Property  @{Label="Address";Expression={$Address}}, `
                                           @{Label="Balance";Expression={$_.balance}}, `
                                           @{Label="BalanceFloat";Expression={$_.balance/100000000}}, `
                                           @{Label="UnconfirmedBalance";Expression={$_.unconfirmedBalance}}, `
                                           @{Label="UnconfirmedBalanceFloat";Expression={$_.unconfirmedBalance/100000000}}
    }
}

##########################################################################################################################################################################################################

<#
.SYNOPSIS
    Get the public key of an account.

.DESCRIPTION
    Return Public Key of account. [String]

.PARAMETER URL
    Address of the target full node server processing the API query.

.PARAMETER Address
    Address of account.

.EXAMPLE
    $AccountPublicKey = Get-PsArkAccountPublicKey -URL https://api.arknode.net/ -Address AHWHraW7xREemYCtxRx4YR2paiqGtgrX2M

#>

Function Get-PsArkAccountPublicKey {

    Param(
        [parameter(Mandatory = $True)]
        [ValidateSet("DevNet","MainNet")]
        [System.String] $Network,

        [parameter(Mandatory = $True)]
        [System.String] $Address
        )

    $Peer = Find-PsArkPeer -Network $Network
    $URL = "$($Peer.IP):$($Peer.Port)"

    $Private:Output = Invoke-PsArkApiCall -Method Get -URL $( $URL+'/api/accounts/getPublicKey?address='+$Address )
    if( $Output.success -eq $True )
    {
        $Output | Select-Object -ExpandProperty publicKey
    }
}

##########################################################################################################################################################################################################

<#
.SYNOPSIS
    Get the list of vote(s) of an account.

.DESCRIPTION
    Return a list of currently voted delegate(s) from account. [Array]

    The list (array) contain custom 'Delegate' object with following properties:

        Name                       : Delegate name of the account. [String]

        Address                    : Address of account. [String]

        PublicKey                  : Public Key of account. [String]

        Vote                       : Total number of vote of the account in 'satoshi'. [String]
                                 1.1 Ark = 110000000 Value

        VoteFloat                  : Total number of vote of the account in 'float'. [Double]
                                 1.1 Ark = 1.1 Value

        ProducedBlocks             : Number of forged block(s) by the account. [Int32]

        MissedBlocks               : Number of missed block(s) by the account. [Int32]

        Rate                       : Delegate rank [Int32]

        Approval                   : Delegate vote approval [Decimal]

        Productivity               : Delegate productivity [Decimal]

.PARAMETER URL
    Address of the target full node server processing the API query.

.PARAMETER Address
    Address of account.

.EXAMPLE
    $AccountVoteList = Get-PsArkAccountVoteList -URL https://api.arknode.net/ -Address AHWHraW7xREemYCtxRx4YR2paiqGtgrX2M

#>

Function Get-PsArkAccountVoteList {

    Param(
        [parameter(Mandatory = $True)]
        [ValidateSet("DevNet","MainNet")]
        [System.String] $Network,

        [parameter(Mandatory = $True)]
        [System.String] $Address
        )

    $Peer = Find-PsArkPeer -Network $Network
    $URL = "$($Peer.IP):$($Peer.Port)"

    $Private:Output = Invoke-PsArkApiCall -Method Get -URL $( $URL+'/api/accounts/delegates?address='+$Address )
    if( $Output.success -eq $True )
    {
        $Output | Select-Object -ExpandProperty delegates | Select-Object -Property @{Label="Name";Expression={$_.username}}, `
                                                                                    @{Label="Address";Expression={$_.address}}, `
                                                                                    @{Label="PublicKey";Expression={$_.publicKey}}, `
                                                                                    @{Label="Vote";Expression={$_.vote}}, `
                                                                                    @{Label="VoteFloat";Expression={$_.vote/100000000}}, `
                                                                                    @{Label="ProducedBlocks";Expression={$_.producedblocks}}, `
                                                                                    @{Label="MissedBlocks";Expression={$_.missedblocks}}, `
                                                                                    @{Label="Rate";Expression={$_.rate}}, `
                                                                                    @{Label="Approval";Expression={$_.approval}}, `
                                                                                    @{Label="Productivity";Expression={$_.productivity}}
    }
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

<#
NO MORE IN OFFICIAL DOCUMENTATION

DEPRECATED !?
#>

Function Get-PsArkAccountSecondSignature {

    # TODO
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

<#

Generate public key

Returns the public key of the provided secret key.

POST /api/accounts/generatePublicKey

Request

{
  "secret": "secret key of account"
}

Response

{
  "success": true,
  "publicKey": "Public key of account. Hex"
}

#>

Function New-PsArkAccount {

<#
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $True)] [string] $Secret
        )

    $Private:Output = Invoke-PsArkApiCall -Method Post -URL $( $Script:PsArk_URL+'accounts/generatePublicKey' ) -Body @{secret=$Secret}
    if( $Output.success -eq $True )
    {
        New-Object PSObject -Property @{
            'PublicKey'  = $Output.publicKey
            'Address'    = 'NOT CODED YET!'
            }
    }
#>
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

<#
Open account

Request information about an account.

POST /api/accounts/open

Request

{
  "secret": "secret key of account"
}

Response

{
  "success": true,
  "account": {
    "address": "Address of account. String",
    "unconfirmedBalance": "Unconfirmed balance of account. String",
    "balance": "Balance of account. String",
    "publicKey": "Public key of account. Hex",
    "unconfirmedSignature": "If account enabled second signature, but it's still not confirmed. Integer",
    "secondSignature": "If account enabled second signature. Integer",
    "secondPublicKey": "Second public key of account. Hex",
    "multisignatures": "Multisignatures. Array"
    "u_multisignatures": "uMultisignatures. Array"
  }
}

#>

Function Open-PsArkAccount
{
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $True)] [string] $Secret
        )

    $Private:Output = Invoke-PsArkApiCall -Method Post -URL $( $Script:PsArk_URL+'accounts/open' ) -Body @{secret=$Secret}
    if( $Output.success -eq $True ) { $Output.account }
}

##########################################################################################################################################################################################################

<#
Put delegates

Vote for the selected delegates. Maximum of 33 delegates at once.

PUT /api/accounts/delegates

Request

{
    "secret" : "Secret key of account",
    "publicKey" : "Public key of sender account, to verify secret passphrase in wallet. Optional, only for UI",
    "secondSecret" : "Secret key from second transaction, required if user uses second signature",
    "delegates" : "Array of string in the following format: ["+DelegatePublicKey"] OR ["-DelegatePublicKey"]. Use + to UPvote, - to DOWNvote"
}

Response

{
   "success": true,
   "transaction": {
      "type": "Type of transaction. Integer",
      "amount": "Amount. Integer",
      "senderPublicKey": "Sender public key. String",
      "requesterPublicKey": "Requester public key. String",
      "timestamp": "Time. Integer",
      "asset":{
         "votes":[
            "+VotedPublickKey",
            "-RemovedVotePublicKey"
         ]
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

Example - No Second Secret

curl -k -H "Content-Type: application/json" \
-X PUT -d '{"secret":"<INSERT SECRET HERE>","publicKey"="<INSERT PUBLICKEY HERE>","delegates":["<INSERT DELEGATE PUBLICKEY HERE>"]}' \
http://localhost:8000/api/accounts/delegates

Example - With Second Secret

curl -k -H "Content-Type: application/json" \
-X PUT -d '{"secret":"<INSERT SECRET HERE>","publicKey"="<INSERT PUBLICKEY HERE>",secondSecret"="<INSERT SECONDSECRET HERE>,"delegates":["<INSERT DELEGATE PUBLICKEY HERE>"]}' \
http://localhost:8000/api/accounts/delegates

Example - Multiple Votes

curl -k -H "Content-Type: application/json" \
-X PUT -d '{"secret":"<INSERT SECRET HERE>","publicKey"="<INSERT PUBLICKEY HERE>","delegates":["<INSERT DELEGATE PUBLICKEY HERE>","<INSERT DELEGATE PUBLICKEY HERE>"]}' \
http://localhost:8000/api/accounts/delegates
#>

Function Add-PsArkAccountVote {

    # TODO
    # Add support for PublickKey, Address, Delegate Name
    # Validate NbEntry >=1 && <= 33 ???
}

##########################################################################################################################################################################################################

<#
Make Add Help and copy-paste/modify
#>

Function Remove-PsArkAccountVote {

    # TODO - Code Add-PsArkAccountVote and copy-paste/modify
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

Function Add-PsArkAccountSecondSignature {

    # TODO
}



##########################################################################################################################################################################################################
### API Call: Loader - Provides the synchronization and loading information of a client. These API calls will only work if the client is syncing or loading.
##########################################################################################################################################################################################################

<#
.SYNOPSIS
    Get the synchronisation status of the client.

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

Function Get-PsArkLoadingStatus {

    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $True)]
        [ValidateSet("DevNet","MainNet")]
        [System.String] $Network
        )

    $Peer = Find-PsArkPeer -Network $Network
    $URL = "$($Peer.IP):$($Peer.Port)"

    $Private:Output = Invoke-PsArkApiCall -Method Get -URL $( $URL+'/api/loader/status' )
    if( $Output.Success -eq $True )
    {
        $Output | Select-Object -Property  @{Label="Loaded";Expression={$_.loaded}}, `
                                           @{Label="Now";Expression={$_.now}}, `
                                           @{Label="BlocksCount";Expression={$_.blocksCount}}
    }
}

##########################################################################################################################################################################################################

<#
Lisk is different.

   "syncing": "Is wallet is syncing with another peers? Boolean: true or false",
   "blocks": "Number of blocks remaining to sync. Integer",
   "height": "Total blocks in blockchain. Integer",
   "broadhash": "Block propagation efficiency and reliability. String",
   "consensus": "Efficiency (%). Integer"
#>

<#
.SYNOPSIS
    Get the synchronisation status of the client.

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

Function Get-PsArkSyncStatus {

    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $True)]
        [ValidateSet("DevNet","MainNet")]
        [System.String] $Network
        )

    $Peer = Find-PsArkPeer -Network $Network
    $URL = "$($Peer.IP):$($Peer.Port)"

    $Private:Output = Invoke-PsArkApiCall -Method Get -URL $( $URL+'/api/loader/status/sync' )
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
    Get the status of last received block.

.DESCRIPTION
    Returns True [Bool] if block was received in the past 120 seconds.

.PARAMETER URL
    Address of the target full node server processing the API query.

.EXAMPLE
    Get-PsArkBlockReceiptStatus -URL https://api.arknode.net/
#>

Function Get-PsArkBlockReceiptStatus {

    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $True)]
        [ValidateSet("DevNet","MainNet")]
        [System.String] $Network
        )
    
    $Peer = Find-PsArkPeer -Network $Network
    $URL = "$($Peer.IP):$($Peer.Port)"

    $Private:Output = Invoke-PsArkApiCall -Method Get -URL $( $URL+'/api/loader/status/ping' )
    if( $Output.Success -ne $NULL ) { $Output.Success }
}

##########################################################################################################################################################################################################
### API Call: Transactions
##########################################################################################################################################################################################################

<#
.SYNOPSIS
    Get information on a specific transaction.

.DESCRIPTION
    Returns a custom object with the following properties:
    
        TransactionID     : ID of the transaction being queried. [String]

        Type              : Type of transaction. [Int32]

        SenderAddress     : Address that sent the transaction. [String]

        RecipientAddress  : Address that received the transaction. [String]

        SenderPublicKey   : Public Key of the transaction sender. [String]

        Signature         : Signature of the transaction. [String]

        Amount            : Amount of Ark transferred

        Fee               : Transaction fee paid. [Int32]

        Confirmations     : Number of times transaction has been confirmed by a delegate. [Int32]

        BlockID           : ID of the block in which the transaction was included. [String]

        Asset             : Object representing tx assets. [PSCustomObject]

        Timestamp         : Integer timestamp of transaction. [Int32]

.PARAMETER URL
    Address of the target full node server processing the API query.

.EXAMPLE
    Get-PsArkTransactionById -URL https://api.arknode.net/ -ID d536c5f30181e9d0771a00f322f25cc42c5a143fe5ce170b91a599912df20228
#>

Function Get-PsArkTransactionById {

    Param(
        [parameter(Mandatory = $True)]
        [ValidateSet("DevNet","MainNet")]
        [System.String] $Network,

        [parameter(Mandatory = $True)]
        [System.String] $ID
        )

    $Peer = Find-PsArkPeer -Network $Network
    $URL = "$($Peer.IP):$($Peer.Port)"

    $Private:Output = Invoke-PsArkApiCall -Method Get -URL $( $URL+'/api/transactions/get?id='+$ID )
    if( $Output.success -eq $True )
    {
        $Output.transaction | Select-Object -Property  @{Label="TransactionID";Expression={$ID}}, `
                                                       @{Label="Type";Expression={$_.type}}, `
                                                       @{Label="SenderAddress";Expression={$_.senderId}}, `
                                                       @{Label="RecipientAddress";Expression={$_.recipientId}}, `
                                                       @{Label="SenderPublicKey";Expression={$_.senderPublicKey}}, `
                                                       @{Label="Signature";Expression={$_.signature}}, `
                                                       @{Label="Amount";Expression={$_.amount}}, `
                                                       @{Label="Fee";Expression={$_.fee}}, `
                                                       @{label="Confirmations";Expression={$_.confirmations}}, `
                                                       @{Label="BlockID";Expression={$_.blockId}}, `
                                                       @{Label="Asset";Expression={$_.asset}}, `
                                                       @{Label="Timestamp";Expression={$_.timestamp}}
    }
}

##########################################################################################################################################################################################################

<#
    Lisk seems to be idential here
#>

<#
    .SYNOPSIS
        Get a list of transactions that match a specific parameter.

    .DESCRIPTION
        Returns an array of custom objects with the following properties:
        
            TransactionID     : ID of the transaction being queried. [String]

            Type              : Type of transaction. [Int32]

            SenderAddress     : Address that sent the transaction. [String]

            RecipientAddress  : Address that received the transaction. [String]

            SenderPublicKey   : Public Key of the transaction sender. [String]

            Signature         : Signature of the transaction. [String]

            Fee               : Transaction fee paid. [Int32]

            Confirmations     : Number of times transaction has been confirmed by a delegate. [Int32]

            BlockID           : ID of the block in which the transaction was included. [String]

            Asset             : Object representing tx assets. [PSCustomObject]

            Timestamp         : Integer timestamp of transaction. [Int32]

    .PARAMETER URL
        Address of the target full node server processing the API query.

    .PARAMETER BlockId
        Id of the block you would like to search for transactions.

    .PARAMETER SenderId
        Address of the sender account to search for related transactions.

    .PARAMETER RecipientId
        Address of the recipient account to search for transactions

    .PARAMETER Offset
        Offset of the transaction to search for

    .PARAMETER ResultSetSize
        Number of transactions to return, defaults to 20

    .PARAMETER MatchAllParameters
        Require all parameters to be matched to return a transaction

    .PARAMETER SortBy
        Choose a parameter to sort the transactions on

    .PARAMETER SortOrder
        sort order, valid options are: asc,desc

    .EXAMPLE
       Get-PsArkTransactionList -URL https://api.arknode.net/ -SenderId AUexKjGtgsSpVzPLs6jNMM6vJ6znEVTQWK -ResultSetSize 2
#>
Function Get-PsArkTransactionList {
    Param(
        
        [Parameter(Mandatory = $True)]
        [System.String] $URL,

        [Parameter(Mandatory = $False)]
        [System.String]$BlockId,

        [Parameter(Mandatory = $False)]
        [System.String]$SenderId,

        [Parameter(Mandatory = $False)]
        [System.String]$RecipientId,

        [Parameter(Mandatory = $False)]
        [System.Int32]$Offset,

        [Parameter(Mandatory = $False)]
        [System.Int32]$ResultSetSize,

        [Parameter(Mandatory = $False)]
        [Switch]$MatchAllParameters,

        [Parameter(Mandatory = $False)]
        [ValidateSet("transactionId","type","senderAddress","recipientAddress","senderPublicKey","signature","fee","confirmations","blockId","asset","timestamp")]
        [System.String]$SortBy = "timestamp",

        [Parameter(Mandatory = $False)]
        [ValidateSet("asc","desc")]
        [System.string]$SortOrder = "desc"
        )

    #Helper function create new query with valid seach params
    
    $Query = "api/transactions?"

    if($BlockId) {
        $Query = Edit-PsArkQuery -Query $Query -NewItem 'BlockId' -NewValue $BlockId
    }

    if($SenderId) {
        $Query = Edit-PsArkQuery -Query $Query -NewItem 'SenderId' -NewValue $SenderId
    }

    if($RecipientId) {
        $Query = Edit-PsArkQuery -Query $Query -NewItem 'RecipientId' -NewValue $RecipientId
    }

    if($Offset) {
        $Query = Edit-PsArkQuery -Query $Query -NewItem 'SenderId' -NewValue $Offset
    }

    if($ResultSetSize) {
        $Query += "&limit=$($ResultSetSize)"
    }

    $Query += "&orderBy=$($SortBy)" + ":" + $SortOrder
    $Private:Output = Invoke-PsArkApiCall -Method Get -URL $( $URL+$Query )

    $Output.transactions | ForEach-Object {$_ | Select-Object -Property @{Label="TransactionID";Expression={$_.ID}}, `
                                                       @{Label="Type";Expression={$_.type}}, `
                                                       @{Label="SenderAddress";Expression={$_.senderId}}, `
                                                       @{Label="RecipientAddress";Expression={$_.recipientId}}, `
                                                       @{Label="SenderPublicKey";Expression={$_.senderPublicKey}}, `
                                                       @{Label="Signature";Expression={$_.signature}}, `
                                                       @{Label="Amount";Expression={$_.amount}}, `
                                                       @{Label="Fee";Expression={$_.fee}}, `
                                                       @{label="Confirmations";Expression={$_.confirmations}}, `
                                                       @{Label="BlockID";Expression={$_.blockId}}, `
                                                       @{Label="Asset";Expression={$_.asset}}, `
                                                       @{Label="Timestamp";Expression={$_.timestamp}}
                                          }
    
}

##########################################################################################################################################################################################################

<#
.SYNOPSIS
    Get information on a specific unconfirmed transaction.

.DESCRIPTION
    Returns a custom object with the following properties:
    
        TransactionID     : ID of the transaction being queried. [String]

        Type              : Type of transaction. [Int32]

        SenderAddress     : Address that sent the transaction. [String]

        RecipientAddress  : Address that received the transaction. [String]

        SenderPublicKey   : Public Key of the transaction sender. [String]

        Signature         : Signature of the transaction. [String]

        Fee               : Transaction fee paid. [Int32]

        Confirmations     : Number of times transaction has been confirmed by a delegate. [Int32]

        BlockID           : ID of the block in which the transaction was included. [String]

        Asset             : Object representing tx assets. [PSCustomObject]

        Timestamp         : Integer timestamp of transaction. [Int32]

.PARAMETER URL
    Address of the target full node server processing the API query.

.PARAMETER ID 
    ID of the transaction to get information on

.EXAMPLE
    Get-PsArkUnconfirmedTransactionById -URL https://api.arknode.net/ -ID d536c5f30181e9d0771a00f322f25cc42c5a143fe5ce170b91a599912df20228
#>

Function Get-PsArkUnconfirmedTransactionById {

    Param(
        [parameter(Mandatory = $True)]
        [System.String] $URL,

        [parameter(Mandatory = $True)]
        [System.String] $ID
        )

    $Private:Output = Invoke-PsArkApiCall -Method Get -URL $( $URL+'api/transactions/unconfirmed/get?id='+$ID )
    if( $Output.success -eq $True )
    {
        $Output.transaction | Select-Object -Property  @{Label="TransactionID";Expression={$_.ID}}, `
                                                       @{Label="Type";Expression={$_.type}}, `
                                                       @{Label="SenderAddress";Expression={$_.senderId}}, `
                                                       @{Label="RecipientAddress";Expression={$_.recipientId}}, `
                                                       @{Label="SenderPublicKey";Expression={$_.senderPublicKey}}, `
                                                       @{Label="Signature";Expression={$_.signature}}, `
                                                       @{Label="Amount";Expression={$_.amount}}, `
                                                       @{Label="Fee";Expression={$_.fee}}, `
                                                       @{label="Confirmations";Expression={$_.confirmations}}, `
                                                       @{Label="BlockID";Expression={$_.blockId}}, `
                                                       @{Label="Asset";Expression={$_.asset}}, `
                                                       @{Label="Timestamp";Expression={$_.timestamp}}
    }
}

##########################################################################################################################################################################################################

<#
.SYNOPSIS
    Get a list of unconfirmed transactions.

.DESCRIPTION
    Returns an array of custom objects with the following properties:
    
        TransactionID     : ID of the transaction being queried. [String]

        Type              : Type of transaction. [Int32]

        SenderAddress     : Address that sent the transaction. [String]

        RecipientAddress  : Address that received the transaction. [String]

        SenderPublicKey   : Public Key of the transaction sender. [String]

        Signature         : Signature of the transaction. [String]

        Fee               : Transaction fee paid. [Int32]

        Confirmations     : Number of times transaction has been confirmed by a delegate. [Int32]

        BlockID           : ID of the block in which the transaction was included. [String]

        Asset             : Object representing tx assets. [PSCustomObject]

        Timestamp         : Integer timestamp of transaction. [Int32]

.PARAMETER URL
    Address of the target full node server processing the API query.

.EXAMPLE
    Get-PsArkUnconfirmedTransactionList -URL https://api.arknode.net/
#>

Function Get-PsArkUnconfirmedTransactionList {

    Param(
        [parameter(Mandatory = $True)]
        [System.String] $URL        
        )

    $Private:Output = Invoke-PsArkApiCall -Method Get -URL $( $URL+'api/transactions/unconfirmed' )
    if( $Output.success -eq $True )
    {
        $Output.transactions | Select-Object -Property @{Label="TransactionID";Expression={$_.ID}}, `
                                                       @{Label="Type";Expression={$_.type}}, `
                                                       @{Label="SenderAddress";Expression={$_.senderId}}, `
                                                       @{Label="RecipientAddress";Expression={$_.recipientId}}, `
                                                       @{Label="SenderPublicKey";Expression={$_.senderPublicKey}}, `
                                                       @{Label="Signature";Expression={$_.signature}}, `
                                                       @{Label="Amount";Expression={$_.amount}}, `
                                                       @{Label="Fee";Expression={$_.fee}}, `
                                                       @{label="Confirmations";Expression={$_.confirmations}}, `
                                                       @{Label="BlockID";Expression={$_.blockId}}, `
                                                       @{Label="Asset";Expression={$_.asset}}, `
                                                       @{Label="Timestamp";Expression={$_.timestamp}}
    }
}

##########################################################################################################################################################################################################

<#
.SYNOPSIS
    Get information on a specific queued transaction.

.DESCRIPTION
    Returns a custom object with the following properties:
    
        TransactionID     : ID of the transaction being queried. [String]

        Type              : Type of transaction. [Int32]

        SenderAddress     : Address that sent the transaction. [String]

        RecipientAddress  : Address that received the transaction. [String]

        SenderPublicKey   : Public Key of the transaction sender. [String]

        Signature         : Signature of the transaction. [String]

        Fee               : Transaction fee paid. [Int32]

        Confirmations     : Number of times transaction has been confirmed by a delegate. [Int32]

        BlockID           : ID of the block in which the transaction was included. [String]

        Asset             : Object representing tx assets. [PSCustomObject]

        Timestamp         : Integer timestamp of transaction. [Int32]

.PARAMETER URL
    Address of the target full node server processing the API query.

.PARAMETER ID 
    ID of the transaction to get information on

.EXAMPLE
    Get-PsArkQueuedTransactionById -URL https://api.arknode.net/ -ID d536c5f30181e9d0771a00f322f25cc42c5a143fe5ce170b91a599912df20228
#>

Function Get-PsArkQueuedTransactionById {

    Param(
        [parameter(Mandatory = $True)]
        [System.String] $URL,

        [parameter(Mandatory = $True)]
        [System.String] $ID
        )

    $Private:Output = Invoke-PsArkApiCall -Method Get -URL $( $URL+'api/transactions/queued/get?id='+$ID )
    if( $Output.success -eq $True )
    {
        $Output.transaction | Select-Object -Property  @{Label="TransactionID";Expression={$ID}}, `
                                                       @{Label="Type";Expression={$_.type}}, `
                                                       @{Label="SenderAddress";Expression={$_.senderId}}, `
                                                       @{Label="RecipientAddress";Expression={$_.recipientId}}, `
                                                       @{Label="SenderPublicKey";Expression={$_.senderPublicKey}}, `
                                                       @{Label="Signature";Expression={$_.signature}}, `
                                                       @{Label="Fee";Expression={$_.fee}}, `
                                                       @{label="Confirmations";Expression={$_.confirmations}}, `
                                                       @{Label="BlockID";Expression={$_.blockId}}, `
                                                       @{Label="Asset";Expression={$_.asset}}, `
                                                       @{Label="Timestamp";Expression={$_.timestamp}}
    }
}

##########################################################################################################################################################################################################

<#
.SYNOPSIS
    Get a list of queued transactions.

.DESCRIPTION
    Returns an array of custom objects with the following properties:
    
        TransactionID     : ID of the transaction being queried. [String]

        Type              : Type of transaction. [Int32]

        SenderAddress     : Address that sent the transaction. [String]

        RecipientAddress  : Address that received the transaction. [String]

        SenderPublicKey   : Public Key of the transaction sender. [String]

        Signature         : Signature of the transaction. [String]

        Fee               : Transaction fee paid. [Int32]

        Confirmations     : Number of times transaction has been confirmed by a delegate. [Int32]

        BlockID           : ID of the block in which the transaction was included. [String]

        Asset             : Object representing tx assets. [PSCustomObject]

        Timestamp         : Integer timestamp of transaction. [Int32]

.PARAMETER URL
    Address of the target full node server processing the API query.

.EXAMPLE
    Get-PsArkUnconfirmedTransactionList -URL https://api.arknode.net/
#>

Function Get-PsArkQueuedTransactionList {

    Param(
        [parameter(Mandatory = $True)]
        [System.String] $URL        
        )

    $Private:Output = Invoke-PsArkApiCall -Method Get -URL $( $URL+'api/transactions/queued' )
    if( $Output.success -eq $True )
    {
        $Output.transaction | Select-Object -Property  @{Label="TransactionID";Expression={$ID}}, `
                                                       @{Label="Type";Expression={$_.type}}, `
                                                       @{Label="SenderAddress";Expression={$_.senderId}}, `
                                                       @{Label="RecipientAddress";Expression={$_.recipientId}}, `
                                                       @{Label="SenderPublicKey";Expression={$_.senderPublicKey}}, `
                                                       @{Label="Signature";Expression={$_.signature}}, `
                                                       @{Label="Fee";Expression={$_.fee}}, `
                                                       @{label="Confirmations";Expression={$_.confirmations}}, `
                                                       @{Label="BlockID";Expression={$_.blockId}}, `
                                                       @{Label="Asset";Expression={$_.asset}}, `
                                                       @{Label="Timestamp";Expression={$_.timestamp}}
    }
}

##########################################################################################################################################################################################################



<#
    .SYNOPSIS
        Creates and sends a transaction
    .DESCRIPTION
        Sends a transaction on the specified network and retuns the transaction ID as a string
    .PARAMETER Network
        A string specifying the network to send the transaction on.  Accepts "DevNet" or "MainNet"
    .PARAMETER Secret
        Passphrase for the account to send ARK from
    .PARAMETER Amount
        Ammount of ARK to send in satoshi
    .PARAMETER Recipient
        Address to send ARK to
    .PARAMETER VendorField
        String to be passed as the vendorfield for the transaction
    .PARAMETER SecondSecret
        NOT YET IMPLEMENTED!! Second secret for sending accounts with dual signatures
#>

Function Send-PsArkTransaction {

  [CmdletBinding()]
  Param(
      [parameter(Mandatory = $True)]
      [ValidateSet("DevNet","MainNet")]
      [System.String] $Network,

      [parameter(Mandatory = $True)]
      [System.String] $Secret,

      [parameter(Mandatory = $True)]
      [System.String] $Amount,

      [parameter(Mandatory = $True)]
      [System.String] $Recipient,

      [parameter(Mandatory = $True)]
      [System.String] $VendorField,

      [parameter(Mandatory = $False)]
      [System.String] $SecondSecret=''
      )

    $Transaction = Create-PsArkTransaction -RecipientId $recipient -SatoshiAmount $Amount -VendorField $VendorField -PassPhrase $Secret
    $Body = @{transactions = @($Transaction)}

    $NetworkInfo = $Script:Network_Data.$Network
    $Peer = Find-PsArkPeer -Network $Network
    $Port = $Peer.Port
    $Version = $Script:PsArk_Version
    $URL = "http://$($peer.IP):$($peer.Port)/peer/transactions"
    
    $Headers = @{
        Version = $Version
        Port = $Port
        NetHash = $NetworkInfo.nethash        
    }

    $Private:Output =Invoke-PsArkApiCall -URL $URL -Method "Post" -Body $Body -Headers $Headers
    if( $Output.success -eq $True )
    {
        return $Output.transactionIds
    }
}


##########################################################################################################################################################################################################
### API Call: Peers
##########################################################################################################################################################################################################

<#
    Lisk ONLY

    "state":"1 - disconnected. 2 - connected. 0 - banned. Integer",
    "broadhash":"Peer block propagation efficiency and reliability. String",
#>

<#
.SYNOPSIS
    Get a single peer details using IP & Port.

.DESCRIPTION
    Return a custom object with following properties:

        IP       : Requested IP. [String]

        Port     : Requested Port. [Int32]

        Version  : Client Version. [String]

        OS       : Operating System. [String]

        Height   : BlockChain Height. [Int32]

        Status   : Client Status. (See note below) [String]

        Delay    : (Undocumented) [Int32]


    Status Property can have multiple values.

        OK         : Normal Status.

        # Ark Internal Errors

        FORK       : Peer is not in sync. with network.
        EAPI       : Returned data does not match API requirement.
        ENETHASH   : Peer is not on the same network.
        ERESPONSE  : Received bad response code.

        # Popsicle Errors

        EUNAVAILABLE  : Unable to connect to the remote URL.
        ETIMEOUT      : Request has exceeded the allowed timeout

        Many others Status are possible, see https://github.com/blakeembrey/popsicle#errors for more infos.

.PARAMETER URL
    Address of the target full node server processing the API query.

.PARAMETER IP
    IP of the chosen peer.

.PARAMETER Port
    Port of the chosen peer.

.EXAMPLE
    $PeerInfo = Get-PsArkPeer -URL https://api.arknode.net/ -IP 149.56.126.216 -Port 4001

#>

Function Get-PsArkPeer {

    Param(
        [parameter(Mandatory = $True)]
        [System.String] $URL,

        [parameter(Mandatory = $True)]
        [System.String] $IP,

        [parameter(Mandatory = $True)]
        [System.Int32] $Port
        )

    $Private:Output = Invoke-PsArkApiCall -Method Get -URL $( $URL+'api/peers/get?ip=' + $IP + '&port=' + $Port )

    if( $Output.success -eq $True )
    {
        $Output.peer | Select-Object -Property  @{Label="IP";Expression={$IP}}, `
                                                @{Label="Port";Expression={$Port}}, `
                                                @{Label="Version";Expression={$_.version}}, `
                                                @{Label="OS";Expression={$_.os}}, `
                                                @{Label="Height";Expression={[Int32] $_.height}}, `
                                                @{Label="Status";Expression={$_.status}}, `
                                                @{Label="Delay";Expression={$_.delay}}
    }
}

##########################################################################################################################################################################################################

<#
Lisk is VERY different! Filter parameters are needed like limit and offset to get full list.

Return the list of peers from provided filter parameters. [Array]
All Filter parameters are optional.
If more then one filter is used, they are join by OR.
If no filter is used, the default values are used.

State       Filter peer by state.
OS          Filter peer by os.
Version     Filter peer by version.
Limit       Limit the number of results returned. Default (Max) to 100.
Offset      Offset of returned results in the peers list. Default to 0.

if( $OS -ne '' )
{
    if( $ApiQuery -eq '' ) { $ApiQuery = $ApiQuery + '?os=' + $OS }
    else { $ApiQuery = $ApiQuery + '&os=' + $OS }
}

if( $ApiQuery -eq '' ) { $ApiQuery = $ApiQuery + '?limit=' + $Limit }
else { $ApiQuery = $ApiQuery + '&limit=' + $Limit }

if( $ApiQuery -eq '' ) { $ApiQuery = $ApiQuery + '?offset=' + $Offset }
else { $ApiQuery = $ApiQuery + '&offset=' + $Offset }

GET /api/peers?state=state&os=os&version=version&limit=limit&offset=offset&orderBy=orderBy

    state: State of peer. 1 - disconnected. 2 - connected. 0 - banned. (Integer)
    os: OS of peer. (String)
    version: Version of peer. (String)
    limit: Limit to show. Max limit is 100. (Integer)
    offset: Offset to load. (Integer)
    orderBy: Name of column to order. After column name must go "desc" or "acs" to choose order type. (String)

All parameters joins by "OR".

Example:    /api/peers?state=1&version=0.3.2 looks like: state=1 OR version=0.3.2

Ark is simpler. All peers are returned and filtering is done in native language.
#>

<#
.SYNOPSIS
    Gets list of peers.

.DESCRIPTION
    Return the list of peers. [Array]

    The list (array) contain custom 'Peer' object with following properties:

        IP       : Requested IP. [String]

        Port     : Requested Port. [Int32]

        Version  : Client Version. [String]

        OS       : Operating System. [String]

        Height   : BlockChain Height. [Int32]

        Status   : Client Status. (See note below) [String]

        Delay    : (Undocumented) [Int32]


        Status Property can have multiple values.

        OK            : Normal Status.
        EUNAVAILABLE  : Unable to connect to the remote URL.
        ETIMEOUT      : Request has exceeded the allowed timeout

.PARAMETER URL
    Address of the target full node server processing the API query.

.EXAMPLE
    $PeerList = Get-PsArkPeerList -URL https://api.arknode.net/

#>

Function Get-PsArkPeerList {

    Param(
        [parameter(Mandatory = $True)]
        [System.String] $URL
        )

    $Private:Output = Invoke-PsArkApiCall -Method Get -URL $( $URL+'api/peers' )
    if( $Output.success -eq $True )
    {
        $Output.peers | Select-Object -Property @{Label="IP";Expression={$_.ip}}, `
                                                @{Label="Port";Expression={$_.port}}, `
                                                @{Label="Version";Expression={$_.version}}, `
                                                @{Label="OS";Expression={$_.os}}, `
                                                @{Label="Height";Expression={[Int32] $_.height}}, `
                                                @{Label="Status";Expression={$_.status}}, `
                                                @{Label="Delay";Expression={$_.delay}}
    }
}

##########################################################################################################################################################################################################

<#
DISABLED: Lisk Only. Irrelevent for Ark since only v1.0.0 & empty Build are returned so far ...

Get peer version and build time

Function Get-PsArkPeerVersion {

    Param(
        [parameter(Mandatory = $True)]
        [System.String] $URL
        )

    $Private:Output = Invoke-PsArkApiCall -Method Get -URL $( $URL+'api/peers/version' )
    if( $Output.success -eq $True )
    {
        $Output.peers | Select-Object -Property @{Label="Version";Expression={$_.version}}, `
                                                @{Label="Build";Expression={$_.build}}
    }
}

#>

Function Find-PsArkPeer {
    Param(
        [ValidateSet("DevNet","MainNet")]
            [System.String]$Network
    )

    $Selectednetwork = $Script:Network_Data.$Network    

    while (!$PeerList) {
        $InitialSeed = Get-Random -InputObject $Selectednetwork.peers
        $PeerList =  Get-PsArkPeerList -URL "$InitialSeed/"
    }
    $currentVersion = $PeerList |
        Where-Object -FilterScript {$_.Version -like "*.*.*"} |
        Measure-Object -Property Version -Maximum |
        Select-object -ExpandProperty Maximum
    
    Return $PeerList | Where-Object -FilterScript {$_.Version -eq $currentVersion} | Get-Random
    
}

##########################################################################################################################################################################################################
### API Call: Block / Blockchain
##########################################################################################################################################################################################################

<#
.SYNOPSIS
    Get a single block details using BlockID.

.DESCRIPTION
    Return a custom object with following properties:

        ID                       : ID. [String]

        Version                  : Version. [Int32]

        Timestamp                : Timestamp. [Int32]

        Height                   : Height. [Int32]

        PreviousBlockID          : Previous Block ID. [String]

        Signature                : Block Signature. [String]

        ConfirmCount             : Total # of block confirmation(s). [Int32]
        
        TransactionCount         : # of transaction(s) included in the block. [Int32]

        TransactionTotalAmount   : Included Transaction(s) Total Amount. [Int32]

        TransactionTotalFee      : Included Transaction(s) Total Fee. [Int32]
        
        ForgerPublicKey          : Forger's Account Public Key. [String]

        ForgerAddress            : Forger's Account Address. [String]
        
        ForgerBaseReward         : Forger's Base Reward. [Int32]

        ForgerFinalReward        : Forger's Final Reward. [Int32]

        PayloadLength            : Payload Length. [Int32]

        PayloadHash              : Payload Hash. [Int32]

.PARAMETER URL
    Address of the target full node server processing the API query.

.PARAMETER ID
    BlockID matching the requested block.

.EXAMPLE
    $BlockInfo = Get-PsArkBlockByID -URL https://api.arknode.net/ -ID 5330406843623440624

#>

Function Get-PsArkBlockByID {

    Param(
        [parameter(Mandatory = $True)]
        [System.String] $URL,

        [parameter(Mandatory = $True)]
        [System.String] $ID
        )

    $Private:Output = Invoke-PsArkApiCall -Method Get -URL $( $URL+'api/blocks/get?id=' + $ID )
    if( $Output.success -eq $True )
    {
        $Output.block | Select-Object -Property @{Label="ID";Expression={$_.id}}, `
                                                @{Label="Version";Expression={$_.version}}, `
                                                @{Label="Timestamp";Expression={$_.timestamp}}, `
                                                @{Label="Height";Expression={$_.height}}, `
                                                @{Label="PreviousBlockID";Expression={$_.previousBlock}}, `
                                                @{Label="Signature";Expression={$_.blockSignature}}, `
                                                @{Label="ConfirmCount";Expression={$_.confirmations}}, `

                                                @{Label="TransactionCount";Expression={$_.numberOfTransactions}}, `
                                                @{Label="TransactionTotalAmount";Expression={$_.totalAmount}}, `
                                                @{Label="TransactionTotalFee";Expression={$_.totalFee}}, `
                                                
                                                @{Label="ForgerPublicKey";Expression={$_.generatorPublicKey}}, `
                                                @{Label="ForgerAddress";Expression={$_.generatorId}}, `
                                                @{Label="ForgerBaseReward";Expression={$_.reward}}, `
                                                @{Label="ForgerFinalReward";Expression={$_.totalForged}}, `
                                                
                                                @{Label="PayloadLength";Expression={$_.payloadLength}}, `
                                                @{Label="PayloadHash";Expression={$_.payloadHash}}
    }
}

##########################################################################################################################################################################################################

<#
.SYNOPSIS
    Get a single block details using Block Height.

.DESCRIPTION
    Return a custom object with following properties:

        ID                       : ID. [String]

        Version                  : Version. [Int32]

        Timestamp                : Timestamp. [Int32]

        Height                   : Height. [Int32]

        PreviousBlockID          : Previous Block ID. [String]

        Signature                : Block Signature. [String]

        ConfirmCount             : Total # of block confirmation(s). [Int32]
        
        TransactionCount         : # of transaction(s) included in the block. [Int32]

        TransactionTotalAmount   : Included Transaction(s) Total Amount. [Int32]

        TransactionTotalFee      : Included Transaction(s) Total Fee. [Int32]
        
        ForgerPublicKey          : Forger's Account Public Key. [String]

        ForgerAddress            : Forger's Account Address. [String]
        
        ForgerBaseReward         : Forger's Base Reward. [Int32]

        ForgerFinalReward        : Forger's Final Reward. [Int32]

        PayloadLength            : Payload Length. [Int32]

        PayloadHash              : Payload Hash. [Int32]

.PARAMETER URL
    Address of the target full node server processing the API query.

.PARAMETER Height
    Block Height matching the requested block.

.EXAMPLE
    $BlockInfo = Get-PsArkBlockByHeight -URL https://api.arknode.net/ -Height 723647

#>

Function Get-PsArkBlockByHeight {

    Param(
        [parameter(Mandatory = $True)]
        [System.String] $URL,

        [parameter(Mandatory = $True)]
        [System.String] $Height
        )

    $Private:Output = Invoke-PsArkApiCall -Method Get -URL $( $URL+'api/blocks?height=' + $Height )
    if( $Output.success -eq $True )
    {
        $Output.blocks | Select-Object -Property @{Label="ID";Expression={$_.id}}, `
                                                @{Label="Version";Expression={$_.version}}, `
                                                @{Label="Timestamp";Expression={$_.timestamp}}, `
                                                @{Label="Height";Expression={$_.height}}, `
                                                @{Label="PreviousBlockID";Expression={$_.previousBlock}}, `
                                                @{Label="Signature";Expression={$_.blockSignature}}, `
                                                @{Label="ConfirmCount";Expression={$_.confirmations}}, `

                                                @{Label="TransactionCount";Expression={$_.numberOfTransactions}}, `
                                                @{Label="TransactionTotalAmount";Expression={$_.totalAmount}}, `
                                                @{Label="TransactionTotalFee";Expression={$_.totalFee}}, `
                                                
                                                @{Label="ForgerPublicKey";Expression={$_.generatorPublicKey}}, `
                                                @{Label="ForgerAddress";Expression={$_.generatorId}}, `
                                                @{Label="ForgerBaseReward";Expression={$_.reward}}, `
                                                @{Label="ForgerFinalReward";Expression={$_.totalForged}}, `
                                                
                                                @{Label="PayloadLength";Expression={$_.payloadLength}}, `
                                                @{Label="PayloadHash";Expression={$_.payloadHash}}
    }
}

##########################################################################################################################################################################################################

<#
.SYNOPSIS
    Get a single block details using Previous Block ID.

.DESCRIPTION
    Return a custom object with following properties:

        ID                       : ID. [String]

        Version                  : Version. [Int32]

        Timestamp                : Timestamp. [Int32]

        Height                   : Height. [Int32]

        PreviousBlockID          : Previous Block ID. [String]

        Signature                : Block Signature. [String]

        ConfirmCount             : Total # of block confirmation(s). [Int32]
        
        TransactionCount         : # of transaction(s) included in the block. [Int32]

        TransactionTotalAmount   : Included Transaction(s) Total Amount. [Int32]

        TransactionTotalFee      : Included Transaction(s) Total Fee. [Int32]
        
        ForgerPublicKey          : Forger's Account Public Key. [String]

        ForgerAddress            : Forger's Account Address. [String]
        
        ForgerBaseReward         : Forger's Base Reward. [Int32]

        ForgerFinalReward        : Forger's Final Reward. [Int32]

        PayloadLength            : Payload Length. [Int32]

        PayloadHash              : Payload Hash. [Int32]

.PARAMETER URL
    Address of the target full node server processing the API query.

.PARAMETER ID
    Previous Block ID matching the requested block.

.EXAMPLE
    $BlockInfo = Get-PsArkBlockByPreviousBlockID -URL https://api.arknode.net/ -ID 443216682634022798

#>

Function Get-PsArkBlockByPreviousBlockID {

    Param(
        [parameter(Mandatory = $True)]
        [System.String] $URL,

        [parameter(Mandatory = $True)]
        [System.String] $ID
        )

    $Private:Output = Invoke-PsArkApiCall -Method Get -URL $( $URL+'api/blocks?previousBlock=' + $ID )
    if( $Output.success -eq $True )
    {
        $Output.blocks | Select-Object -Property @{Label="ID";Expression={$_.id}}, `
                                                @{Label="Version";Expression={$_.version}}, `
                                                @{Label="Timestamp";Expression={$_.timestamp}}, `
                                                @{Label="Height";Expression={$_.height}}, `
                                                @{Label="PreviousBlockID";Expression={$_.previousBlock}}, `
                                                @{Label="Signature";Expression={$_.blockSignature}}, `
                                                @{Label="ConfirmCount";Expression={$_.confirmations}}, `

                                                @{Label="TransactionCount";Expression={$_.numberOfTransactions}}, `
                                                @{Label="TransactionTotalAmount";Expression={$_.totalAmount}}, `
                                                @{Label="TransactionTotalFee";Expression={$_.totalFee}}, `
                                                
                                                @{Label="ForgerPublicKey";Expression={$_.generatorPublicKey}}, `
                                                @{Label="ForgerAddress";Expression={$_.generatorId}}, `
                                                @{Label="ForgerBaseReward";Expression={$_.reward}}, `
                                                @{Label="ForgerFinalReward";Expression={$_.totalForged}}, `
                                                
                                                @{Label="PayloadLength";Expression={$_.payloadLength}}, `
                                                @{Label="PayloadHash";Expression={$_.payloadHash}}
    }
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

<#
.SYNOPSIS
    Gets list of peers.

.DESCRIPTION
    Return the list of peers. [Array]

    The list (array) contain custom 'Peer' object with following properties:

        IP       : Requested IP. [String]

        Port     : Requested Port. [Int32]

        Version  : Client Version. [String]

        OS       : Operating System. [String]

        Height   : BlockChain Height. [Int32]

        Status   : Client Status. (See note below) [String]

        Delay    : (Undocumented) [Int32]


        Status Property can have multiple values.

        OK            : Normal Status.
        EUNAVAILABLE  : Unable to connect to the remote URL.
        ETIMEOUT      : Request has exceeded the allowed timeout

.PARAMETER URL
    Address of the target full node server processing the API query.

.EXAMPLE
    $PeerList = Get-PsArkPeerList -URL https://api.arknode.net/

#>

<#
Function Get-PsArkPeerList {

    Param(
        [parameter(Mandatory = $True)]
        [System.String] $URL
        )

    $Private:Output = Invoke-PsArkApiCall -Method Get -URL $( $URL+'api/peers' )
    if( $Output.success -eq $True )
    {
        $Output.peers | Select-Object -Property @{Label="IP";Expression={$_.ip}}, `
                                                @{Label="Port";Expression={$_.port}}, `
                                                @{Label="Version";Expression={$_.version}}, `
                                                @{Label="OS";Expression={$_.os}}, `
                                                @{Label="Height";Expression={[Int32] $_.height}}, `
                                                @{Label="Status";Expression={$_.status}}, `
                                                @{Label="Delay";Expression={$_.delay}}
    }
}
#>

# Get-PsArkBlockListByTransactionTotalAmount
# Get-PsArkBlockListByTransactionTotalFee
# Get-PsArkBlockListByForgerPublicKey


Function Get-PsArkBlockList {

    Param(
        [parameter(Mandatory = $True)]
        [System.String] $URL,

        
        [parameter(Mandatory = $False)]
    [System.String] $TotalFee='',

        [parameter(Mandatory = $False)]
    [System.String] $TotalAmount='',
        [parameter(Mandatory = $False)]
    [System.String] $GeneratorPublicKey='',

        [parameter(Mandatory = $False)]
    [System.String] $Limit='',

        [parameter(Mandatory = $False)]
    [System.String] $Offset='',

        [parameter(Mandatory = $False)]
    [System.String] $OrderBy=''
        )

  if( ( $TotalFee -eq '' ) -and ( $TotalAmount -eq '' ) -and ( $PreviousBlock -eq '' ) -and ( $Height -eq '' ) -and ( $GeneratorPublicKey -eq '' ) -and ( $Limit -eq '' ) -and ( $Offset -eq '' ) -and ( $OrderBy -eq '' ) )
  {
    Write-Warning 'Get-LiskBlockList | The usage of at least one parameter is mandatory. Nothing to do.'
  }
  else
  {
    $Private:Query = '?'

    if( $TotalFee -ne '' )
    {
      if( $Query -ne '?' ) { $Query += '&' }
      $Query += "totalFee=$TotalFee"
    }
    if( $TotalAmount -ne '' )
    {
      if( $Query -ne '?' ) { $Query += '&' }
      $Query += "totalAmount=$TotalAmount"
    }
    if( $PreviousBlock -ne '' )
    {
      if( $Query -ne '?' ) { $Query += '&' }
      $Query += "previousBlock=$PreviousBlock"
    }
    if( $Height -ne '' )
    {
      if( $Query -ne '?' ) { $Query += '&' }
      $Query += "height=$Height"
    }
    if( $GeneratorPublicKey -ne '' )
    {
      if( $Query -ne '?' ) { $Query += '&' }
      $Query += "generatorPublicKey=$GeneratorPublicKey"
    }
    if( $Limit -ne '' )
    {
      if( $Query -ne '?' ) { $Query += '&' }
      $Query += "limit=$Limit"
    }
    if( $Offset -ne '' )
    {
      if( $Query -ne '?' ) { $Query += '&' }
      $Query += "offset=$Offset"
    }
    if( $OrderBy -ne '' )
    {
      if( $Query -ne '?' ) { $Query += '&' }
      $Query += "orderBy=$OrderBy"
    }

    #$Private:Output = Invoke-LwdApiCall -Method Get -URI $( $URI+'api/blocks'+$Query )
    #if( $Output.success -eq $True ) { $Output.blocks }
  }

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
Get Signature Fees

Gets the second signature status of an account.

GET /api/signatures/fee

Response

"fee" : Integer
#>

Function Get-PsArkBlockchainSignatureFee {

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

  [CmdletBinding()]
    Param(
        [parameter(Mandatory = $True)]
    [System.String] $URI,

    [parameter(Mandatory = $True)]
    [System.String] $PublicKey
        )

  $Private:Output = Invoke-LwdApiCall -Method Get -URI $( $URI+'api/delegates/get?publicKey='+$PublicKey )
  if( $Output.success -eq $True ) { $Output.delegate }

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

    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $True)]
    [System.String] $URI,

    [parameter(Mandatory = $True)]
    [System.String] $PublicKey
        )

  $Private:Output = Invoke-LwdApiCall -Method Get -URI $( $URI+'api/delegates/voters?publicKey='+$PublicKey )
  if( $Output.success -eq $True ) { $Output.accounts }

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

  [CmdletBinding()]
  Param(
      [parameter(Mandatory = $True)]
      [System.String] $URI,

      [parameter(Mandatory = $True)]
      [System.String] $GeneratorPublicKey
      )

  $Private:Output = Invoke-LwdApiCall -Method Get -URI $( $URI+'api/delegates/forging/getForgedByAccount?generatorPublicKey='+$GeneratorPublicKey )
  if( $Output.success -eq $True )
  {
    $Output | Select-Object -Property fees, rewards, forged
  }
}

##########################################################################################################################################################################################################



<#
Undocumented
#>

Function Get-PsArkDelegateForgingStatus {

    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $True)]
    [System.String] $URI,

    [parameter(Mandatory = $True)]
    [System.String] $PublicKey
        )

  $Private:Output = Invoke-LwdApiCall -Method Get -URI $( $URI+'api/delegates/forging/status?publicKey='+$PublicKey )
  if( $Output.success -eq $True ) { $Output.enabled }

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

  [CmdletBinding()]
  Param(
      [parameter(Mandatory = $True)]
      [System.String] $URI
      )

  $Private:Output = Invoke-LwdApiCall -Method Get -URI $( $URI+'api/delegates/getNextForgers?limit=101' )
  if( $Output.success -eq $True )
  {
    $Output | Select-Object -Property CurrentBlock, CurrentSlot, Delegates
  }
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

    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $True)]
    [System.String] $URI,

        [parameter(Mandatory = $True)]
    [System.String] $Secret
        )

  $Private:Output = Invoke-LwdApiCall -Method Post -URI $( $URI+'api/delegates/forging/enable' ) -Body @{secret=$Secret}

  Write-Host "DEBUG | Enable-LwdDelegateForging"
  Write-Host ( $Output | FL * | Out-String )

  if( $Output.success -eq $True )
  {
    #$Output.publicKey
    <#
    New-Object PSObject -Property @{
      'PublicKey'  = $Output.publicKey
      'Address'    = 'NOT CODED YET!'
      }
    #>
  }
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

   [CmdletBinding()]
    Param(
        [parameter(Mandatory = $True)]
    [System.String] $URI,

        [parameter(Mandatory = $True)]
    [System.String] $Secret
        )

  $Private:Output = Invoke-LwdApiCall -Method Post -URI $( $URI+'api/delegates/forging/disable' ) -Body @{secret=$Secret}

  Write-Host "DEBUG | Disable-LwdDelegateForging"
  Write-Host ( $Output | Format-List * | Out-String )

  if( $Output.success -eq $True )
  {
    #$Output.publicKey
    <#
    New-Object PSObject -Property @{
      'PublicKey'  = $Output.publicKey
      'Address'    = 'NOT CODED YET!'
      }
    #>
  }
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

Function Invoke-PsArkApiCall {

    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $True)]
        [System.String] $URL,

        [parameter(Mandatory = $True)]
        [ValidateSet('Get','Post','Put')]
        [System.String] $Method,

        [parameter(Mandatory = $False)]
        [System.Collections.Hashtable] $Body = @{},

        [parameter(Mandatory = $False)]
        [System.Collections.Hashtable] $Headers = @{}
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
        $Content = $Body | ConvertTo-Json
        Try { $Private:WebRequest = Invoke-WebRequest -URI $URL -Method $Method -Body $Content -Headers $Headers -ContentType 'application/json' }
        Catch { Write-Warning "Invoke-WebRequest FAILED on $URL !" }
    }
    if( ( $WebRequest.StatusCode -eq 200 ) -and ( $WebRequest.StatusDescription -eq 'OK' ) )
    {
        $Private:Result = $WebRequest | ConvertFrom-Json
        if( $Result.success -eq $True ) { $Result }
        else { Write-Warning "Invoke-PsArkApiCall | success => false | error => $($Result.error)" }
    }
    else { Write-Warning "Invoke-PsArkApiCall | WebRequest returned Status '$($WebRequest.StatusCode) $($WebRequest.StatusDescription)'."; return $WebRequest }
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

Function Edit-PsArkQuery($Query, $NewItem, $NewValue) {
        
        if($Query.substring($Query.length - 1) -and ($Query[-1] -ne "?")) {
            $Query += "&"
        } elseif($MatchAllParameters) {
            Return $($Query) + "AND:" + $($NewItem) + "=" + $NewValue
        } else {
            Return $($Query) + $($NewItem) + "=" + $NewValue
        }
    }

##########################################################################################################################################################################################################

Function Get-PsArkTimeStamp {
    $Begin = [datetime]::new(2017, 3, 21, 13, 00, 0, [System.DateTimeKind]::Utc)
    $Time = [System.Convert]::ToInt32(([datetime]::UtcNow - $Begin).TotalMilliseconds / 1000)
    Return $Time
}
#########################################################################################################################################################################################################

Function Get-PsArkKey ($PassPhrase) {
    $SHA256 = [System.Security.Cryptography.SHA256]::Create()
    $PassBytes = [System.Text.Encoding]::ASCII.GetBytes($PassPhrase)
    $Hash = $SHA256.ComputeHash($PassBytes)
    $Key = [NBitcoin.Key]::new($Hash)
    Return $Key
}
#########################################################################################################################################################################################################
function Get-PsArkTransactionBytes ($Transaction) {
    
    $timestampInt = [System.Decimal]::ToInt32($transaction.TimeStamp)
    $timeStampBytes = [System.BitConverter]::GetBytes($timestampInt)
    [int]$arrayLength = 1   #this tracks teh position of the byte array and works around the lack of a bytebuffer

    $publicKeyBytes = [NBitcoin.DataEncoders.Encoders]::Hex.DecodeData($transaction.senderPublicKey)
    $arrayLength += $publicKeyBytes.length

    $arrayLength += $timeStampBytes.length
    
    $RecipientBytes = [NBitcoin.DataEncoders.Encoders]::Base58Check.DecodeData($transaction.RecipientId)
    $arrayLength += $RecipientBytes.length

    if($transaction.vendorField) {
        $Vendorbytes = [System.Text.Encoding]::ASCII.GetBytes($transaction.vendorField)
        if($Vendorbytes.Length -lt 65) {
            $VBytes = [System.Byte[]]::CreateInstance([System.Byte], 64)
            $Vendorbytes.CopyTo($VBytes,0)
        }
    } else {
        $VBytes = [System.Byte[]]::CreateInstance([System.Byte], 64)
    }
    $arrayLength += $VBytes.length

    $Amount = [System.BitConverter]::GetBytes($transaction.Amount)
    $arrayLength += $Amount.length
    $TXFee = [System.BitConverter]::GetBytes($transaction.Fee)
    $arrayLength += $TXFee.length

    if($Transaction.Signature -ne $null) {
        $Signature = [NBitcoin.DataEncoders.Encoders]::Hex.DecodeData($Transaction.Signature)
        
    } else {
        $Signature = $null
    }
    $arrayLength += $Signature.length    
    
    $i = 0

    $Bytes = [System.Byte[]]::CreateInstance([System.Byte], ($arrayLength))
    $Bytes.SetValue($Transaction.Type, $i)
    $i += 1
    
    $timeStampBytes.CopyTo($Bytes,$i)
    $i += $timeStampBytes.Length

    $publicKeyBytes.CopyTo($Bytes,$i)
    $i += $publicKeyBytes.Length

    $RecipientBytes.CopyTo($Bytes,$i)
    $i += $RecipientBytes.Length

    $VBytes.CopyTo($Bytes,$i)
    $i += $VBytes.Length
    
    $Amount.CopyTo($Bytes,$i)
    $i += $Amount.length
    
    $TXFee.CopyTo($Bytes,$i)
    $i += $TXFee.Length

    $Signature.CopyTo($Bytes,$i)
    $i += $Signature.Length
    
    return $Bytes
}
#########################################################################################################################################################################################################

Function Sign-PsArkTransaction ($Transaction, $PassPhrase){
    
    $Bytes = Get-PsArkTransactionBytes -Transaction $transaction

    $keys = Get-PsArkKey $passphrase
    $SHA256 = [System.Security.Cryptography.SHA256]::Create()
    $hash = $SHA256.ComputeHash($Bytes)
    $Uhash = [NBitcoin.uint256]::new($hash)
    $signature = $keys.Sign($Uhash)
    $signature = $signature.ToDER()
    $signature = [NBitcoin.DataEncoders.Encoders]::Hex.EncodeData($signature)
    $transaction.signature = $signature
    Return $transaction
}
#########################################################################################################################################################################################################

Function Get-PsArkTransactionId ($Transaction){
    $SHA256 = [System.Security.Cryptography.SHA256]::Create()
    $TXBytes = Get-PsArkTransactionBytes -Transaction $Transaction
    $Hash = $SHA256.ComputeHash($TXBytes)
    [NBitcoin.DataEncoders.Encoders]::Hex.EncodeData($Hash)
}
#########################################################################################################################################################################################################

<#
.SYNOPSIS
    Create a new signed transaction on the selected Ark Network
.DESCRIPTION
    Returns a custom object with the following properties:
        id                : ID of the transaction being queried. [String]

        type              : Type of transaction. [Int32]

        recipientId       : Address that received the transaction. [String]

        SenderPublicKey   : Public Key of the transaction sender. [String]

        Signature         : Signature of the transaction. [String]

        fee               : Transaction fee paid. [Int32]

        asset             : Object representing tx assets. [PSCustomObject]

        timestamp         : Integer timestamp of transaction. [Int32]

        vendorField       : String to be sent as the vendorfield [string]

        amount            : Integer representing the "satoshi" amount of ark to send
.PARAMETER RecipientId
    String representing the address of the wallet to which ARK is being sent
.PARAMETER SatoshiAmount
    Long Int representing the "satoshi" value of the ARK to be sent
.PARAMETER PassPhrase
    11 word passphrase for sending wallet
.PARAMETER Fee
    Long Int representing the "satoshi" value of the transaction fee to be paid
.PARAMETER Type
    Byte value representing the type of transaction to be sent, currently only type 0 implemented
.PARAMETER Asset
    Asset object to be sent with transaction, not currently implemented
.PARAMETER Network
    String representing the network that should be used for the transaction, currently only MAINET and DEVNET implemented
.EXAMPLE
    Create-PsArkTransaction -RecipientId "DHytfsYZtpJeiNTBuysm4eP41dSwpieFY2" -SatoshiAmount 1100000000 -VendorField "Testing PsArk" -PassPhrase "11 word passphrase" -Fee 10000000 -Network "Devnet" -type 0
#>
Function Create-PsArkTransaction {
    [cmdletbinding()]
        param(
            [string]$RecipientId,        
            [long]$SatoshiAmount,
            [string]$VendorField,
            [string]$PassPhrase,
            [long]$Fee = 10000000,
            [byte]$Type,
            [PSCustomObject]$Asset,
            [ValidateSet("MainNet","Devnet")]
              [string]$NetWork
        )
    
    $Transaction = [ordered]@{
        id = ""
        timestamp = Get-PsArkTimeStamp
        recipientId = $RecipientId
        amount = $SatoshiAmount
        fee = $Fee
        type = [byte]0   #Right now only supporting type 0 tx's will expand to support other typles later
        vendorField = $VendorField
        signature = ""
        senderPublicKey = Get-PsArkPublicKey -PassPhrase $PassPhrase
    }
    
    if($Asset) {
        $Transaction.asset = $Asset
    }

    $Transaction = Sign-PsArkTransaction -Transaction $Transaction -passphrase $PassPhrase
    $Transaction.Id = Get-PsArkTransactionId -Transaction $Transaction
    Return $Transaction
}
#########################################################################################################################################################################################################
Function Get-PsArkPublicKey ($PassPhrase) {
    Return [NBitcoin.DataEncoders.Encoders]::Hex.EncodeData((Get-PsArkKey -PassPhrase $passphrase).PubKey.toBytes())
}
##### Export Public Functions #####

#### API ############################################################################

# Account #--------------------------------------------------------------------------

Export-ModuleMember -Function Get-PsArkAccount
Export-ModuleMember -Function Get-PsArkAccountBalance
Export-ModuleMember -Function Get-PsArkAccountPublicKey
Export-ModuleMember -Function Get-PsArkAccountVoteList
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

Export-ModuleMember -Function Get-PsArkTransactionById
Export-ModuleMember -Function Get-PsArkTransactionList
Export-ModuleMember -Function Get-PsArkUnconfirmedTransactionById
Export-ModuleMember -Function Get-PsArkUnconfirmedTransactionList
#Export-ModuleMember -Function Get-PsArkQueuedTransactionById
#Export-ModuleMember -Function Get-PsArkQueuedTransactionList

# Export-ModuleMember -Function Create-PsArkTransaction
Export-ModuleMember -Function Send-PsArkTransaction

# Peers #----------------------------------------------------------------------------

Export-ModuleMember -Function Get-PsArkPeer
Export-ModuleMember -Function Get-PsArkPeerList

# Block / Blockchain #--------------------------------------------------------------

Export-ModuleMember -Function Get-PsArkBlockById
Export-ModuleMember -Function Get-PsArkBlockByHeight
Export-ModuleMember -Function Get-PsArkBlockByPreviousBlockID

#Export-ModuleMember -Function Get-PsArkBlockList
#Export-ModuleMember -Function Get-PsArkBlockchainTransactionFee
#Export-ModuleMember -Function Get-PsArkBlockchainSignatureFee
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
#Export-ModuleMember -Function Get-PsArkDelegateForgingStatus
#Export-ModuleMember -Function Get-PsArkDelegateNextForgers

#Export-ModuleMember -Function New-PsArkDelegateAccount
#Export-ModuleMember -Function Search-PsArkDelegate
#Export-ModuleMember -Function Enable-PsArkDelegateForging
#Export-ModuleMember -Function Disable-PsArkDelegateForging

# Multi-Signature #------------------------------------------------------------------

#Export-ModuleMember -Function Get-PsArkMultiSigPendingTransactionList
#Export-ModuleMember -Function Get-PsArkMultiSigAccountList

#Export-ModuleMember -Function New-PsArkMultiSigAccount
#Export-ModuleMember -Function Approve-PsArkMultiSigTransaction


#### Misc. Functions ################################################################

Export-ModuleMember -Function Show-PsArkAbout
