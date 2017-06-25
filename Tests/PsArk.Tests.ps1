if(Get-Module PsArk) {
    Remove-Module PsArk
}
Import-Module ./PsArk

InModuleScope PsArk {
    Describe "Invoke-PsArkApiCall" {
        $SampleReturn = Import-Clixml -Path "$($PSScriptRoot)/SampleObjects/SampleWebResponse.xml"

        #mock for each request method
        Mock Invoke-WebRequest {Return $SampleReturn} -ModuleName "PsArk" -Verifiable -ParameterFilter {($URI -eq "http://mainnetURL.com/api/") -and ($Method -eq "get")}
        Mock Invoke-WebRequest {Return $SampleReturn} -ModuleName "PsArk" -Verifiable -ParameterFilter {($URI -eq "http://mainnetURL.com/api/") -and ($Method -eq "put")}
        Mock Invoke-WebRequest {Return $SampleReturn} -ModuleName "PsArk" -Verifiable -ParameterFilter {($URI -eq "http://mainnetURL.com/api/") -and ($Method -eq "post") -and ($Body = "testbody")}
        
        $GetTest = Invoke-PsArkApiCall -URL "http://mainnetURL.com/api/" -Method "Get"
        $PutTest = Invoke-PsArkApiCall -URL "http://mainnetURL.com/api/" -Method "Put"
        $PostTest = Invoke-PsArkApiCall -URL "http://mainnetURL.com/api/" -Method "Post" -Body @{test = "testbody"}

        #These tests eventually need to be broken out into individual tests with Assert-MockCalled but I haven't used it yet
        It "Makes a call all three programmed methods and a fourth with a body" {
            Assert-VerifiableMocks
        }

        It "Returns a valid webresponse object from each of the requests" {
            $GetTest.success | Should Be true
            $PutTest.success | Should Be true
            $PostTest.success | Should Be true

            $GetTest.peers[1].port | Should Be 4001
            
        }


    }
    Describe "Get-PsArkAccount" {
        $SampleAct = @{
            success = $true
            account = @{
                address = "Address"
                balance = 110000000
            }
        }

        Mock Invoke-PsArkApiCall {Return $SampleAct} -ModuleName "PsArk" -Verifiable -ParameterFilter {$URL -eq "http://mainnetURL.com/api/accounts?address=Address"}

        $Account = Get-PsArkAccount -URL "http://mainnetURL.com/" -Address "Address"

        It "Queries the provided URL for information on the specified account" {
            Assert-VerifiableMocks
        }
        It "Returns an account object with basic properties passed through" {
            $Account.Address | Should Be "Address"
            $Account.Balance | Should Be 110000000
        }
    }
    Describe "Get-PsArkAccountBalance" {
        $SampleAct = @{
            success = $true
                address = "Address"
                balance = 110000000
        }

        Mock Invoke-PsArkApiCall {Return $SampleAct} -ModuleName "PsArk" -Verifiable -ParameterFilter { $URL -eq "http://mainnetURL.com/api/accounts/getBalance/?address=Address"}
    
        $AccountBalance = Get-PsArkAccountBalance -URL 'http://mainnetURL.com/' -Address 'Address'

        It "Queries the provided URL for the balance of the specified account" {
            Assert-VerifiableMocks
        }
        It "Returns an object with an address, balance, and balancefloat" {
            $AccountBalance.Address | Should Be "Address"
            $AccountBalance.Balance | Should Be 110000000
            $AccountBalance.BalanceFloat | Should Be 1.1
        }
    }
    Describe "Get-PsArkAccountPublicKey" {
        #Actual custom object required here rather than a hash table due to how the select is performed in the moduld
        #Possible we should shift all test objects to this style of declaration but it's quite verbose
        $SampleKey = [PsCustomObject]@{
            success = $True
            publicKey = "PublicKey"
        }

        Mock Invoke-PsArkApiCall {Return $SampleKey} -ModuleName "PsArk" -Verifiable -ParameterFilter { $URL -eq "http://mainnetURL.com/api/accounts/getPublicKey?address=Address"}

        $Key = Get-PsArkAccountPublicKey -URL "http://mainnetURL.com/" -Address "Address"

        It "Calls to the ark API for a public key associated with the string passed to the -Address param" {
            Assert-VerifiableMocks
        }
        It "Returns a Public Key" {
            $Key | Should be "PublicKey"
        }        
    }
    Describe "Get-PsArkAccountVoteList" {
        $SampleVoteList = [PsCustomObject]@{
            success = $True
            delegates = @{
                username = "username"
                vote = 110000000
            }
        }

        Mock Invoke-PsArkApiCall {Return $SampleVoteList} -ModuleName "PsArk" -Verifiable -ParameterFilter { $URL -eq "http://mainnetURL.com/api/accounts/delegates?address=Address"}

        $votes = Get-PsArkAccountVoteList -URL "http://mainnetURL.com/" -Address "Address"
        
        It "Queries the Ark api for the vote list of the specified account" {
            Assert-VerifiableMocks
        }
        
        It "Returns a valid vote list object" {
            $votes.name | Should Be "username"
            $votes.vote | Should Be 110000000
            $votes.voteFloat | Should Be 1.1
        }

    }
    Describe "Get-PsArkLoadingStatus" {
        
        $SampleStatus = @{
            success = $True
            loaded = $True
        }

        Mock Invoke-PsArkApiCall {Return $SampleStatus} -ModuleName "PsArk" -Verifiable -ParameterFilter { $URL -eq "http://mainnetURL.com/api/loader/status"}

        $Status = Get-PsArkLoadingStatus -URL 'http://mainnetURL.com/'

        It "Queries the specified URL for the client status" {
            Assert-VerifiableMocks
        }

        It "Returns a valid status object" {
            $Status.loaded | Should Be $True
        }
    }

    Describe "Get-PsArkSyncStatus" {

        $SampleStatus = @{
            success = $true
            syncing = $true
        }

        Mock Invoke-PsArkApiCall {Return $SampleStatus} -ModuleName "PsArk" -Verifiable -ParameterFilter { $URL -eq "http://mainnetURL.com/api/loader/status/sync"}

        $Status = Get-PsArkSyncStatus -URL "http://mainnetURL.com/"

        It "Queries the specified URL for the nodes syncstatus" {
            Assert-VerifiableMocks
        }
        It "Returns a Sync Status object" {
            $Status.syncing | Should Be $True
        }
    }
    Describe "Get-PsArkBlockReceiptStatus" {

        $SampleStatus = @{
            success = $true
        }
        
        Mock Invoke-PsArkApiCall {Return $SampleStatus} -ModuleName "PsArk" -Verifiable -ParameterFilter { $URL -eq "http://mainnetURL.com/api/loader/status/ping"}
        
        $Status = Get-PsArkBlockReceiptStatus -URL "http://mainnetURL.com/"

        It "Queries the specified URL for the nodes block receipt status" {
            Assert-VerifiableMocks
        }
        It "Returns a bool" {
            $Status | Should Be $true
            $Status | Should BeOfType [bool]
        }
    }

    Describe "Get-PsArkTransactionById" {

        $SampleTx = @{
            Success = $true
            Transaction = @{
                ID = "txID"
                Amount = 1000
            }
        }
    
        Mock Invoke-PsArkApiCall {Return $SampleTx} -ModuleName "PsArk" -Verifiable -ParameterFilter { $URL -eq "http://mainnetURL.com/api/transactions/get?id=txID"}
        
        $TransactionInfo = Get-PsArkTransactionById -URL 'http://mainnetURL.com/' -ID 'txID'

        It "Queries the provided URL for a transaction with the ID passed in the ID parameter" {
            Assert-VerifiableMocks
        }
        
        It "Returns an object with basic tx parameters" {
            $TransactionInfo.TransactionID | Should Be "txID"
            $TransactionInfo.Amount | Should Be 1000
        }        
    }

    Describe "Get-PsArkTransactionList" {
        $SampleTxArr = @{
            Success = $True
            Transactions = @(
                @{                    
                    ID = "txID"
                    Amount = 1000                    
                },
                @{
                    ID = "txID2"
                    Amount = 13000
                }
            )
        }
        

        Mock Invoke-PsArkApiCall {Return $SampleTxArr} -ModuleName "PsArk" -Verifiable -ParameterFilter { $URL -eq "http://mainnetURL.com/api/transactions?SenderId=senderID&orderBy=timestamp:desc"}

        $Transactions = Get-PsArkTransactionList -URL 'http://mainnetURL.com/' -SenderId 'senderID'
                
        It "Queries the provided URL for all transactions with a sender ID passed in the SenderID parameter" {
            Assert-VerifiableMocks
        }    
        It "Returns an array of transactionss" {
            $Transactions[0].TransactionID | Should Be "txID"
            $Transactions[1].Amount | Should Be  13000
        }
    }

    Describe "Get-PsArkUnconfirmedTransactionById" {

        $SampleTx = @{
            Success = $true
            Transaction = @{
                ID = "txID"
                Amount = 1000
            }
        }
    
        Mock Invoke-PsArkApiCall {Return $SampleTx} -ModuleName "PsArk" -Verifiable -ParameterFilter { $URL -eq "http://mainnetURL.com/api/transactions/unconfirmed/get?id=txID"}
        
        $TransactionInfo = Get-PsArkUnconfirmedTransactionById -URL 'http://mainnetURL.com/' -ID 'txID'

        It "Queries the provided URL for a transaction with the ID passed in the ID parameter" {
            Assert-VerifiableMocks
        }
        
        It "Returns an object with basic tx parameters" {
            $TransactionInfo[0].TransactionID | Should Be "txID"
            $TransactionInfo[0].Amount | Should Be 1000
        }        
    }
    
    Describe "Get-PsArkUnconfirmedTransactionList" {
        $SampleTxArr = @{
            Success = $True
            Transactions = @(
                @{                    
                    ID = "txID"
                    Amount = 1000                    
                },
                @{
                    ID = "txID2"
                    Amount = 13000
                }
            )
        }
        

        Mock Invoke-PsArkApiCall {Return $SampleTxArr} -ModuleName "PsArk" -Verifiable -ParameterFilter { $URL -eq "http://mainnetURL.com/api/transactions/unconfirmed"}

        $Transactions = Get-PsArkUnconfirmedTransactionList -URL 'http://mainnetURL.com/'
                
        It "Queries the provided URL for all transactions with a sender ID passed in the SenderID parameter" {
            Assert-VerifiableMocks
        }    
        It "Returns an array of transactionss" {
            $Transactions[0].TransactionID | Should Be "txID"
            $Transactions[1].Amount | Should Be  13000
        }
    }
    Describe "Get-PsArkPeer" {

        $SamplePeer = @{
            success = $True
            peer = @{
                IP = "ipAddress"
                status = "status"
            }
        }

        Mock Invoke-PsArkApiCall {Return $SamplePeer} -ModuleName "PsArk" -Verifiable -ParameterFilter {$URL -eq "http://mainnetURL.com/api/peers/get?ip=ipAddress&port=4001"}

        $Peer = Get-PsArkPeer -URL "http://mainnetURL.com/" -IP "ipAddress" -Port 4001

        It "Queries the provided URL for peer information" {
            Assert-VerifiableMocks
        }
        It "Returns a Peer" {
            $Peer.IP | Should Be "ipAddress"
            $Peer.status | Should Be "status"
        }
    }
    Describe "Get-PsArkPeerList" {
        $SamplePeers = @{
            success = $true
            peers = @(
                @{
                    IP = "ipAddress"
                    status = "status"
                },
                @{
                    IP = "ipAddress"
                    status = "status"
                }
            )
        }

        Mock Invoke-PsArkApiCall {Return $SamplePeers} -ModuleName "PsArk" -Verifiable -ParameterFilter {$URL -eq "http://mainnetURL.com/api/peers"}

        $Peers = Get-PsArkPeerList -URL "http://mainnetURL.com/"

        It "Queries the provided URL for a list of peers" {
            Assert-VerifiableMocks
        }
        It "Returns an array of peers" {
            $Peers[1].IP | Should Be "ipAddress"
            $Peers[0].status | Should Be "status"
        }
    }
    Describe "Get-PsArkBlockByID" {
        $SampleBlock = @{
            success = $True
            block = @{
                id = "blockID"
                version = "version"
            }
        }

        Mock Invoke-PsArkApiCall {Return $SampleBlock} -ModuleName "PsArk" -Verifiable -ParameterFilter {$URL -eq "http://mainnetURL.com/api/blocks/get?id=blockID"}

        $Block = Get-PsArkBlockByID -URL "http://mainnetURL.com/" -ID "blockID"

        It "Queries the specified URL for a block with the specified ID" {
            Assert-VerifiableMocks
        }
        It "Returns a Block" {
            $Block.ID | Should Be "blockID"
            $Block.version | Should Be "version"
        }
    }
    Describe "Get-PsArkBlockByHeight" {
        $SampleBlock = @{
            success = $True
            blocks = @{
                id = "blockID"
                version = "version"
                height = 723647
            }
        }

        Mock Invoke-PsArkApiCall {Return $SampleBlock} -ModuleName "PsArk" -Verifiable -ParameterFilter {$URL -eq "http://mainnetURL.com/api/blocks?height=723647"}

        $Block = Get-PsArkBlockByHeight -URL "http://mainnetURL.com/" -Height 723647

        It "Queries the specified URL for a block with the specified ID" {
            Assert-VerifiableMocks
        }
        It "Returns a Block" {
            $Block.ID | Should Be "blockID"
            $Block.version | Should Be "version"
            $Block.height | Should Be 723647
        }
    }
    Describe "Get-PsArkBlockByPreviousBlockID" {
        $SampleBlock = @{
            success = $True
            blocks = @{
                id = "blockID"
                version = "version"
                height = 723647
            }
        }
        
        Mock Invoke-PsArkApiCall {Return $SampleBlock} -ModuleName "PsArk" -Verifiable -ParameterFilter {$URL -eq "http://mainnetURL.com/api/blocks?previousBlock=blockID"}

        $Block = Get-PsArkBlockByPreviousBlockID -URL "http://mainnetURL.com/" -ID "blockID"

        It "Queries the provided URL for the block after the indicated block" {
            Assert-VerifiableMocks
        }
        It "Returns a Block" {
            $Block.ID | Should Be "blockID"
            $Block.version | Should Be "version"
            $Block.height | Should Be 723647
        }
    }

}
