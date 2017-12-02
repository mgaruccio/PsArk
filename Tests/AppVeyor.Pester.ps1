# This script will invoke pester tests

#Initialize variables and configure environment
$TestFile = "TestResultsPS$($PSVersion).xml"
$ProjectRoot = $ENV:APPVEYOR_BUILD_FOLDER
Set-Location $ProjectRoot


#Invoke Pester tests and store the resuls in an xml file
Invoke-Pester -Path "$($ProjectRoot)\Tests" -OutputFormat NUnitXml -OutputFile "$($ProjectRoot)\$($TestFile)" -PassThru |
    Export-Clixml -Path "$($ProjectRoot)\PesterResults.xml"

#Upload results to appveyor
$Address = "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)"
$Source = "$($ProjectRoot)\PesterResults.xml"

"UPLOADING FILE: $($Address) $($Source)"

(New-Object 'System.Net.WebClient').UploadFile( $Address, $Source )

#Check results and print failures to console
$Results = "$($ProjectRoot)\PesterResults.xml" | Import-Clixml

$FailedCount = $Results |
    Select-Object -ExpandProperty FailedCount |
    Measure-Object -Sum |
    Select-Object -ExpandProperty Sum


if ($FailedCount -gt 0) {    
    $FailedItems = $Results |
        Select-Object -ExpandProperty TestResult |
        Where-Object {$_.Passed -notlike $True}

    "FAILED TESTS SUMMARY:`n"
    $FailedItems | ForEach-Object {
        $Test = $_
        [pscustomobject]@{
            Describe = $Test.Describe
            Context = $Test.Context
            Name = "It $($Test.Name)"
            Result = $Test.Result
        }
    } |
        Sort-Object Describe, Context, Name, Result |
        Format-List

    throw "$FailedCount tests failed."
}

