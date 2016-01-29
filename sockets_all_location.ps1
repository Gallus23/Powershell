
add-pssnapin -name VMware.VimAutomation.Core

$vcenter = @( 
    "icdwpvcdvcs002.dcsprod.dcsroot.local", 
	"nj2wpvcdvcs002.dcsprod.dcsroot.local", 
	"lo1wpvcdvcs002.dcsprod.dcsroot.local", 
    "lo3wpvcdvcs002.dcsprod.dcsroot.local", 
	"au1wpvcdvcs002.dcsprod.dcsroot.local", 
	"bj1wpvcdvcs002.dcsprod.dcsroot.local", 
	"sh1wpvcdvcs002.dcsprod.dcsroot.local", 
	"sg8wpvcdvcs002.dcsprod.dcsroot.local",
    "bz1wpvcdvcs002.dcsprod.dcsroot.local"
);


# Connect 
Connect-VIServer -Server $vcenter -User $vCenterUsername -Password $vCenterPassword


foreach($vc in $vcenter){

$location = $vc.Substring(0,3)
$outfile = "d:\mike\" + $location + "-info.csv"

Get-VMHost |Sort Name |Get-View |
Select Name, 
@{N=“Type“;E={$_.Hardware.SystemInfo.Vendor+ “ “ + $_.Hardware.SystemInfo.Model}},
@{N=“CPU“;E={“PROC:“ + $_.Hardware.CpuInfo.NumCpuPackages + “ CORES:“ + $_.Hardware.CpuInfo.NumCpuCores + “ MHZ: “ + [math]::round($_.Hardware.CpuInfo.Hz / 1000000, 0)}},
@{N=“MEM“;E={“” + [math]::round($_.Hardware.MemorySize / 1GB, 0) + “ GB“}}| Export-Csv $outfile


}
		

disconnect-viserver -server * -Confirm:$false -force