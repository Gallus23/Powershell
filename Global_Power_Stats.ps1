d:
\software\scripts
. .\create-chart.ps1
. .\create-HashTable.ps1

cd \myStackOps\Images
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

# Store your U&P 
$vCenterUsername = "mystackops@dcsutil.dcsroot.local"
$vCenterPassword = "#0rs3Sh03"

# Connect 
Connect-VIServer -Server $vcenter -User $vCenterUsername -Password $vCenterPassword

$hashtable = $null
$hash2 = $null
$hash3 = $null

$hashtable = @{}
$hash2 = @{}
$hash3 = @{}

foreach($vc in $vcenter){

	$location = $vc.Substring(0,3)
	$location = $location.toupper()
	$counter = (Get-VM -Server $vc | where {$_.name -notlike "vse*" -and $_.powerstate -eq "PoweredOff"}).count
	$counter2 = (Get-VM -Server $vc | where {$_.name -notlike "vse*" -and $_.powerstate -eq "PoweredOn"}).count
	$counter3 = (Get-VM -Server $vc | where {$_.name -notlike "vse*"}).count
	
	$hashtable.add($location, $counter)
	$hash2.add($location, $counter2)
	$hash3.add($location, $counter3)
}
		
Create-Chart -ChartType Bar -ChartTitle "Powered Off VM's" -FileName Poweredoff -XAxisName "Location" -YAxisName "Quantity" -ChartWidth 450 -ChartHeight 350 -DataHashTable $hashtable
Create-Chart -ChartType Bar -ChartTitle "Powered On VM's" -FileName Poweredon -XAxisName "Location" -YAxisName "Quantity" -ChartWidth 450 -ChartHeight 350 -DataHashTable $hash2
Create-Chart -ChartType Bar -ChartTitle "Total VM's" -FileName total -XAxisName "Location" -YAxisName "Quantity" -ChartWidth 450 -ChartHeight 350 -DataHashTable $hash3

disconnect-viserver -server * -Confirm:$false -force