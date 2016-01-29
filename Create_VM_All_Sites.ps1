
add-pssnapin -name VMware.VimAutomation.Core

$vCenter=@( 
    "icdwpvcdvcs002.dcsprod.dcsroot.local", 
	"nj2wpvcdvcs002.dcsprod.dcsroot.local", 
	"au1wpvcdvcs002.dcsprod.dcsroot.local", 
    "bz1wpvcdvcs002.dcsprod.dcsroot.local")

$vCenterUsername = "administrator@vsphere.local"
$VMname = Get-Date -UFormat "%A-%Y-%m-%d"


foreach ($vc in $vcenter) 
{t
    $location = $vc.Substring(0,3)
    $file = "d:\software\scripts\" + $location + ".xml"
    Get-VICredentialStoreItem -file $file 

    # Connect 
    Connect-VIServer -Server $vCenterIPorFQDN -User $vCenterUsername

    $ESXi = Get-Cluster  | Get-VMHost -state connected | Get-Random
    get-vm -location "DS9-TEST-SYNC" | Remove-VM -DeletePermanently -Confirm:$false
    New-VM -Name $VMname  -Location "DS9-TEST-SYNC" -vmhost $ESXi  -GuestId winLonghorn64Guest
    
}	

disconnect-viserver -server $vCenterIPorFQDN  -Confirm:$false -force