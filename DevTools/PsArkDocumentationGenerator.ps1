<##########################################################################################################################################

Version :	0.1.0.0
Author  :	Gr33nDrag0n
History :	2017/04/21 - Release v0.1.0.0
			2017/04/20 - Creation of the script.

##########################################################################################################################################>

# Patch to generate documentation in english
$OldCulture = [System.Threading.Thread]::CurrentThread.CurrentUICulture
[System.Threading.Thread]::CurrentThread.CurrentUICulture = 'en-US'

##############################################################################

#$CmdletName='Set-PsArkConfiguration'
#Get-Help $CmdletName -Full > "..\Documentation\$CmdletName.txt"

#-----------------------------------------------------------------------------

#$CmdletName='Get-PsArkAccount'
#Get-Help $CmdletName -Full > "..\Documentation\$CmdletName.txt"

#$CmdletName='Get-PsArkAccountBalance'
#Get-Help $CmdletName -Full > "..\Documentation\$CmdletName.txt"

#$CmdletName='Get-PsArkAccountPublicKey'
#Get-Help $CmdletName -Full > "..\Documentation\$CmdletName.txt"

#$CmdletName='Get-PsArkAccountVote'
#Get-Help $CmdletName -Full > "..\Documentation\$CmdletName.txt"

#$CmdletName='New-PsArkAccount'
#Get-Help $CmdletName -Full > "..\Documentation\$CmdletName.txt"

#$CmdletName='Open-PsArkAccount'
#Get-Help $CmdletName -Full > "..\Documentation\$CmdletName.txt"

#-----------------------------------------------------------------------------

#$CmdletName=''
#Get-Help $CmdletName -Full > "..\Documentation\$CmdletName.txt"

##############################################################################

# Restore local default
[System.Threading.Thread]::CurrentThread.CurrentUICulture = $OldCulture
