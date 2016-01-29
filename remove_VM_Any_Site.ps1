param(
	[string]$Location,
    [string]$VMname
	)


add-pssnapin -name VMware.VimAutomation.Core

$vCenterIPorFQDN=$location + "wpvcdvcs002.dcsprod.dcsroot.local"

# Connect 
Connect-VIServer -Server $vCenterIPorFQDN 


Remove-VM $VMname -DeletePermanently -confirm
	

disconnect-viserver -server $vCenterIPorFQDN  -Confirm:$false -force