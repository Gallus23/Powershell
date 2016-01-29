#Variable declaration
param(
	[string]$Location
	)
	
add-pssnapin -name VMware.VimAutomation.Core

$vCenterIPorFQDN=$location + "wpvcdvcs002.dcsprod.dcsroot.local"

#Test connection to destination vCenter
Write-Host "Testing Connection to vCenter" -foregroundcolor "magenta" 
if(!(Test-Connection -Cn $vCenterIPorFQDN -BufferSize 16 -Count 1 -ea 0 -quiet))
{
write-host "Connection to $vCenterIPorFQDN failed cannot ping" -foregroundcolor "red" 
exit
}

$vCenterUsername = "dcsutil\ahowami"
$vCenterPassword = "Screen141"

Write-Host "Connecting to vCenter" -foregroundcolor "magenta" 
Connect-VIServer -Server $vCenterIPorFQDN -User $vCenterUsername -Password $vCenterPassword

$script = @"
driverquery
"@

Get-VM "LO3-Win-BE (80053a75-d5b1-4d4c-9d25-8886235d80f6)" | %{
  $output = Invoke-VMScript -VM $_ -ScriptText $script
  $_ | Select Name,@{N="vShield Agent present";E={$output -match "vsepflt"}}
}


#Disconnect the vCenter
write-host "Disconnecting vSphere......."
disconnect-viserver -server * -Confirm:$false -force