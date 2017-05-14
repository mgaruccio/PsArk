<##########################################################################################################################################

Version :   0.1.0.0
Author  :   Gr33nDrag0n
History :   2017/04/24 - Release v0.1.0.0
            2017/04/20 - Creation of the script.

##########################################################################################################################################>

### RUN FROM EN_US computer for clean output files (all english). !!!

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

$Private:CmdletList = Get-Command -Name '*-PsArk*' | Select-Object -ExpandProperty Name | Where-Object { $_ -ne 'Show-PsArkAbout' }
$Private:CmdletList_Count = $CmdletList | Measure-Object | Select-Object -ExpandProperty Count

Write-Host ''
Write-Host " $CmdletList_Count PsArk cmdlet found."
Write-Host ''
ForEach( $Private:CmdletName in $CmdletList)
{
    Write-Host "Processing: $CmdletName"
    Get-Help $CmdletName -Full > "..\Documentation\$CmdletName.txt"

    # Remove from file
<#
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

#>
}
Write-Host ''
