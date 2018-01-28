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
            Assert-VerifiableMock
        }

        It "Returns a valid webresponse object from each of the requests" {
            $GetTest.success | Should -Be true
            $PutTest.success | Should -Be true
            $PostTest.success | Should -Be true

            $GetTest.peers[1].port | Should -Be 4001
            
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
        $SamplePeer = Import-Clixml -Path ".\Tests\SampleObjects\Peer.xml"
    
        Mock Invoke-PsArkApiCall {Return $SampleAct} -ModuleName "PsArk" -Verifiable -ParameterFilter {$URL -like "*.*.*.*:4002/api/accounts?address=Address"}
        Mock Find-PsArkPeer {return $SamplePeer} -ModuleName "PsArk" -Verifiable
    
        $Account = Get-PsArkAccount -Network "DevNet" -Address "Address"
    
        It "Finds a valid peer and queries it for information on the specified account" {
            Assert-VerifiableMock
        }
        It "Returns an account object with basic properties passed through" {
            $Account.Address | Should -Be "Address"
            $Account.Balance | Should -Be 110000000
        }
    }
    Describe "Get-PsArkAccountBalance" {
        $SampleAct = @{
            success = $true
                address = "Address"
                balance = 110000000
        }
        $SamplePeer = Import-Clixml -Path ".\Tests\SampleObjects\Peer.xml"

        Mock Invoke-PsArkApiCall {Return $SampleAct} -ModuleName "PsArk" -Verifiable -ParameterFilter {$URL -like "*.*.*.*:4002/api/accounts/getBalance/?address=Address"}
        Mock Find-PsArkPeer {return $SamplePeer} -ModuleName "PsArk" -Verifiable
    
        $AccountBalance = Get-PsArkAccountBalance -Network "Devnet" -Address 'Address'

        It "Finds a valid peer and queries it for the balance of the specified account" {
            Assert-VerifiableMock
        }
        It "Returns an object with an address, balance, and balancefloat" {
            $AccountBalance.Address | Should -Be "Address"
            $AccountBalance.Balance | Should -Be 110000000
            $AccountBalance.BalanceFloat | Should -Be 1.1
        }
    }
    Describe "Get-PsArkAccountPublicKey" {
        #Actual custom object required here rather than a hash table due to how the select is performed in the moduld
        #Possible we should shift all test objects to this style of declaration but it's quite verbose
        $SampleKey = [PsCustomObject]@{
            success = $True
            publicKey = "PublicKey"
        }
        $SamplePeer = Import-Clixml -Path ".\Tests\SampleObjects\Peer.xml"

        Mock Invoke-PsArkApiCall {Return $SampleKey} -ModuleName "PsArk" -Verifiable -ParameterFilter { $URL -like "*.*.*.*:4002/api/accounts/getPublicKey?address=Address"}
        Mock Find-PsArkPeer {return $SamplePeer} -ModuleName "PsArk" -Verifiable

        $Key = Get-PsArkAccountPublicKey -Network "DevNet" -Address "Address"

        It "Finds a valid peer and queries it's API for a public key associated with the string passed to the -Address param" {
            Assert-VerifiableMock
        }
        It "Returns a Public Key" {
            $Key | Should -Be "PublicKey"
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
        $SamplePeer = Import-Clixml -Path ".\Tests\SampleObjects\Peer.xml"

        Mock Invoke-PsArkApiCall {Return $SampleVoteList} -ModuleName "PsArk" -Verifiable -ParameterFilter { $URL -like "*.*.*.*:4002/api/accounts/delegates?address=Address"}
        Mock Find-PsArkPeer {return $SamplePeer} -ModuleName "PsArk" -Verifiable

        $votes = Get-PsArkAccountVoteList -Network "DevNet" -Address "Address"
        
        It "Queries the Ark api for the vote list of the specified account" {
            Assert-VerifiableMock
        }
        
        It "Returns a valid vote list object" {
            $votes.name | Should -Be "username"
            $votes.vote | Should -Be 110000000
            $votes.voteFloat | Should -Be 1.1
        }

    }
    Describe "Get-PsArkLoadingStatus" {
        
        $SampleStatus = @{
            success = $True
            loaded = $True
        }
        $SamplePeer = Import-Clixml -Path ".\Tests\SampleObjects\Peer.xml"

        Mock Invoke-PsArkApiCall {Return $SampleStatus} -ModuleName "PsArk" -Verifiable -ParameterFilter { $URL -like "*.*.*.*:4002/api/loader/status"}
        Mock Find-PsArkPeer {return $SamplePeer} -ModuleName "PsArk" -Verifiable

        $Status = Get-PsArkLoadingStatus -Network "DevNet"

        It "Queries the specified URL for the client status" {
            Assert-VerifiableMock
        }

        It "Returns a valid status object" {
            $Status.loaded | Should -Be $True
        }
    }

    Describe "Get-PsArkSyncStatus" {

        $SampleStatus = @{
            success = $true
            syncing = $true
        }
        $SamplePeer = Import-Clixml -Path ".\Tests\SampleObjects\Peer.xml"

        Mock Invoke-PsArkApiCall {Return $SampleStatus} -ModuleName "PsArk" -Verifiable -ParameterFilter { $URL -like "*.*.*.*:4002/api/loader/status/sync"}
        Mock Find-PsArkPeer {return $SamplePeer} -ModuleName "PsArk" -Verifiable

        $Status = Get-PsArkSyncStatus -Network "DevNet"

        It "Queries the specified URL for the nodes syncstatus" {
            Assert-VerifiableMock
        }
        It "Returns a Sync Status object" {
            $Status.syncing | Should -Be $True
        }
    }
    Describe "Get-PsArkBlockReceiptStatus" {

        $SampleStatus = @{
            success = $true
        }
        $SamplePeer = Import-Clixml -Path ".\Tests\SampleObjects\Peer.xml"
        
        Mock Invoke-PsArkApiCall {Return $SampleStatus} -ModuleName "PsArk" -Verifiable -ParameterFilter { $URL -like "*.*.*.*:4002/api/loader/status/ping"}
        Mock Find-PsArkPeer {return $SamplePeer} -ModuleName "PsArk" -Verifiable
        
        $Status = Get-PsArkBlockReceiptStatus -Network "DevNet"

        It "Queries the specified URL for the nodes block receipt status" {
            Assert-VerifiableMock
        }
        It "Returns a bool" {
            $Status | Should -Be $true
            $Status | Should -BeOfType [bool]
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
        $SamplePeer = Import-Clixml -Path ".\Tests\SampleObjects\Peer.xml"
    
        Mock Invoke-PsArkApiCall {Return $SampleTx} -ModuleName "PsArk" -Verifiable -ParameterFilter { $URL -like "*.*.*.*:4002/api/transactions/get?id=txID"}
        Mock Find-PsArkPeer {return $SamplePeer} -ModuleName "PsArk" -Verifiable
        
        $TransactionInfo = Get-PsArkTransactionById -Network "DevNet" -ID 'txID'

        It "Queries the provided URL for a transaction with the ID passed in the ID parameter" {
            Assert-VerifiableMock
        }
        
        It "Returns an object with basic tx parameters" {
            $TransactionInfo.TransactionID | Should -Be "txID"
            $TransactionInfo.Amount | Should -Be 1000
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
        $SamplePeer = Import-Clixml -Path ".\Tests\SampleObjects\Peer.xml"
        

        Mock Invoke-PsArkApiCall {Return $SampleTxArr} -ModuleName "PsArk" -Verifiable -ParameterFilter { $URL -like "*.*.*.*:4002/api/transactions?SenderId=senderID&orderBy=timestamp:desc"}
        Mock Find-PsArkPeer {return $SamplePeer} -ModuleName "PsArk" -Verifiable

        $Transactions = Get-PsArkTransactionList -Network 'DevNet' -SenderId 'senderID'
                
        It "Queries the provided URL for all transactions with a sender ID passed in the SenderID parameter" {
            Assert-VerifiableMock
        }    
        It "Returns an array of transactionss" {
            $Transactions[0].TransactionID | Should -Be "txID"
            $Transactions[1].Amount | Should -Be  13000
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
        $SamplePeer = Import-Clixml -Path ".\Tests\SampleObjects\Peer.xml"
    
        Mock Invoke-PsArkApiCall {Return $SampleTx} -ModuleName "PsArk" -Verifiable -ParameterFilter { $URL -like "*.*.*.*:4002/api/transactions/unconfirmed/get?id=txID"}
        Mock Find-PsArkPeer {return $SamplePeer} -ModuleName "PsArk" -Verifiable

        $TransactionInfo = Get-PsArkUnconfirmedTransactionById -Network "DevNet" -ID 'txID'

        It "Queries the provided URL for a transaction with the ID passed in the ID parameter" {
            Assert-VerifiableMock
        }
        
        It "Returns an object with basic tx parameters" {
            $TransactionInfo[0].TransactionID | Should -Be "txID"
            $TransactionInfo[0].Amount | Should -Be 1000
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
        $SamplePeer = Import-Clixml -Path ".\Tests\SampleObjects\Peer.xml"

        Mock Invoke-PsArkApiCall {Return $SampleTxArr} -ModuleName "PsArk" -Verifiable -ParameterFilter { $URL -like "*.*.*.*:4002/api/transactions/unconfirmed"}
        Mock Find-PsArkPeer {return $SamplePeer} -ModuleName "PsArk" -Verifiable

        $Transactions = Get-PsArkUnconfirmedTransactionList -Network "DevNet"
                
        It "Queries the provided URL for all transactions with a sender ID passed in the SenderID parameter" {
            Assert-VerifiableMock
        }    
        It "Returns an array of transactionss" {
            $Transactions[0].TransactionID | Should -Be "txID"
            $Transactions[1].Amount | Should -Be  13000
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

        Mock Invoke-PsArkApiCall {Return $SamplePeer} -ModuleName "PsArk" -Verifiable -ParameterFilter {$URL -eq "*.*.*.*:4002/api/peers/get?ip=ipAddress&port=4001"}

        $Peer = Get-PsArkPeer -Network "DevNet" -IP "ipAddress" -Port 4001

        It "Queries the provided URL for peer information" {
            Assert-VerifiableMock
        }
        It "Returns a Peer" {
            $Peer.IP | Should -Be "ipAddress"
            $Peer.status | Should -Be "status"
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
            Assert-VerifiableMock
        }
        It "Returns an array of peers" {
            $Peers[1].IP | Should -Be "ipAddress"
            $Peers[0].status | Should -Be "status"
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
            Assert-VerifiableMock
        }
        It "Returns a Block" {
            $Block.ID | Should -Be "blockID"
            $Block.version | Should -Be "version"
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
            Assert-VerifiableMock
        }
        It "Returns a Block" {
            $Block.ID | Should -Be "blockID"
            $Block.version | Should -Be "version"
            $Block.height | Should -Be 723647
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
            Assert-VerifiableMock
        }
        It "Returns a Block" {
            $Block.ID | Should -Be "blockID"
            $Block.version | Should -Be "version"
            $Block.height | Should -Be 723647
        }
    }

    Describe "Find-PsArkPeer" {
        $SamplePeerList = Import-Clixml ".\Tests\SampleObjects\PeerList.xml"
        
        Mock Get-PsArkPeerList {Return $SamplePeerList} -ModuleName "PsArk" -Verifiable -ParameterFilter {($URL -like "*.*.*.*:4002/")}

        $NewPeer = Find-PsArkPeer -Network "Devnet"

        It "Queries PsArkPeerList and Peer endpoints to get a currently working api end point" {
            Assert-VerifiableMock
        }
        It "Returns a peer" {
            $NewPeer.Port | Should -Be 4002
            $Newpeer.Version | Should -BeLike "1.*.*"
        }
    }
    
    Describe "Create-PsArkTransaction" {
        $SampleTxObjectUnsigned = Import-Clixml ".\Tests\SampleObjects\Transaction-Unsigned.xml"
        $SampleTxObjectSigned = Import-Clixml ".\Tests\SampleObjects\Transaction-Signed.xml"
        $SampleTxObjectSignedId = (Import-Clixml ".\Tests\SampleObjects\Transaction-Signed-Id.xml").id
        $SamplePublicKey = "0387199b7480e5081b7fa3972c0f3d20df156f0b3560c00ee7d06fcdc2164f0388"

        $TestPassPhrase = "PassPhrase"

        Mock Get-PsArkTimeStamp {Return $SampleTxObjectUnsigned.Timestamp} -ModuleName "PsArk" -Verifiable
        Mock Get-PsArkPublicKey {Return $SamplePublicKey} -ModuleName "PsArk" -Verifiable 
        Mock Sign-PsArkTransaction {Return $SampleTxObjectSigned} -ModuleName "PsArk" -Verifiable 
        Mock Get-PsArktransactionId {Return $SampleTxObjectSignedId} -ModuleName "PsArk" -Verifiable

        $TX = Create-PsArkTransaction -RecipientId $SampleTxObjectUnsigned.RecipientId -SatoshiAmount $SampleTxObjectUnsigned.amount -VendorField "Testing PsArk" -PassPhrase $TestPassPhrase -Fee $SampleTxObjectUnsigned.fee -Network "Devnet" -type 0

        It "Calls to Get-PsArkTimeStamp for the current ARK formatted time" {
            Assert-MockCalled -CommandName Get-PsArkTimeStamp
        }

        It "Calls to Get-PsArkPublicKey and then correctly formats the public key" {
            Assert-MockCalled -CommandName Get-PsArkPublicKey -ParameterFilter {$passphrase -eq $TestPassPhrase}
            $TX.senderPublicKey | Should -Be "0387199b7480e5081b7fa3972c0f3d20df156f0b3560c00ee7d06fcdc2164f0388"
        }

        It "Calls Sign-PsArkTransaction with the passphrase that was passed into the function and correctly applies the signature to the returned result" {
            Assert-MockCalled -CommandName Sign-PsArkTransaction -ParameterFilter {($Transaction.id -eq $SampleTxObjectUnsigned.id) -and ($passphrase -eq $passphrase)}
            $TX.signature | Should -Be "3045022100eed84eb6bc193f0120717fd894f0019a4cafdeddf22fedf37d3073ac367569870220763a7f3365d3f0bd55c29ceff3bfd8743f456668fb0e171a8535acf37840ec8a"
        }

        It "Calls Get-PsArkTransactionId and correctly applies the ID to the signed transaction" {
            Assert-MockCalled -CommandName Get-PsArkTransactionId  -ParameterFilter {$Transaction.id -eq $SampleTxObjectSigned.id}
            $TX.id | Should -Be "69e7cc0a2eee67f909855bb89ba9a84e5b1fb28468a6f4594a76606cac2602e4"
        }
    }

}
