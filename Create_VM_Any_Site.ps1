param(
	[string]$Location,
    [string]$VMname
	)


add-pssnapin -name VMware.VimAutomation.Core

$vCenterIPorFQDN=$location + "wpvcdvcs002.dcsprod.dcsroot.local"
$vmhost  = $location + "upvcdesx011m.dcsutil.dcsroot.local"

# Connect 
Connect-VIServer -Server $vCenterIPorFQDN 


New-VM -Name $VMname  -vmhost $vmhost -GuestId winLonghorn64Guest
	

#disconnect-viserver -server $vCenterIPorFQDN  -Confirm:$false -force