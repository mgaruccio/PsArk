<#
Function Start-PsArkNetworkMonitor
{

	$Private:Peers = Get-PsArkPeer
	#$Peers | FT
	
	$Private:Peers_Count_Total = $Peers | Measure-Object | Select-Object -ExpandProperty Count
	
	$Private:Peers_Count_Banned = $Peers | Where-Object { $_.state -eq 0 } | Measure-Object | Select-Object -ExpandProperty Count
	$Private:Peers_Count_Disconnected = $Peers | Where-Object { $_.state -eq 1 } | Measure-Object | Select-Object -ExpandProperty Count
	$Private:Peers_Count_Connected = $Peers | Where-Object { $_.state -eq 2 } | Measure-Object | Select-Object -ExpandProperty Count
	
	
	$Private:Peers_000 = $Peers | Where-Object { ( $_.version -ne '0.1.1' ) -and ( $_.version -ne '0.1.2' ) -and ( $_.version -ne '0.1.3' ) }
	$Private:Peers_Count_000 = $Peers_000 | Measure-Object | Select-Object -ExpandProperty Count
	$Private:Peers_Count_011 = $Peers | Where-Object { $_.version -eq '0.1.1' } | Measure-Object | Select-Object -ExpandProperty Count
	$Private:Peers_Count_012 = $Peers | Where-Object { $_.version -eq '0.1.2' } | Measure-Object | Select-Object -ExpandProperty Count
	$Private:Peers_Count_013 = $Peers | Where-Object { $_.version -eq '0.1.3' } | Measure-Object | Select-Object -ExpandProperty Count
	
	Write-Host ''
	Write-Host "Peers Count          => $Peers_Count_Total"
	Write-Host ''
	Write-Host "Peers Connected      => $Peers_Count_Connected"
	Write-Host "Peers Disconnected   => $Peers_Count_Disconnected"
	Write-Host "Peers Banned         => $Peers_Count_Banned"
	Write-Host ''
	Write-Host "Peers v0.1.1         => $Peers_Count_011"
	Write-Host "Peers v0.1.2         => $Peers_Count_012"
	Write-Host "Peers v0.1.3         => $Peers_Count_013"
	Write-Host "Peers v?.?.?         => $Peers_Count_000"
	
	$Peers_000 | FT
}
#>

##########################################################################################################################################################################################################

