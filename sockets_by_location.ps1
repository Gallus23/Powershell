param(
	[string]$Location
	)


add-pssnapin -name VMware.VimAutomation.Core

$vCenterIPorFQDN=$location + "wpvcdvcs002.dcsprod.dcsroot.local"
$outfile = "d:\mike\" + $location + "-info.csv"

# Connect 
Connect-VIServer -Server $vCenterIPorFQDN
Get-VMHost |Sort Name |Get-View |
Select Name, 
@{N=“Type“;E={$_.Hardware.SystemInfo.Vendor+ “ “ + $_.Hardware.SystemInfo.Model}},
@{N=“CPU“;E={“PROC:“ + $_.Hardware.CpuInfo.NumCpuPackages + “ CORES:“ + $_.Hardware.CpuInfo.NumCpuCores + “ MHZ: “ + [math]::round($_.Hardware.CpuInfo.Hz / 1000000, 0)}},
@{N=“MEM“;E={“” + [math]::round($_.Hardware.MemorySize / 1GB, 0) + “ GB“}}| Export-Csv $outfile


disconnect-viserver -server $vCenterIPorFQDN  -Confirm:$false -force