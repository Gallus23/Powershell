Param(
  [Parameter(Mandatory=$True)]
       [string]$vcddns,	
	   
  [Parameter(Mandatory=$True)]
       [string]$user,

  [Parameter(Mandatory=$True)]
       [string]$pwd
  )


$thedate = Get-Date
Write-Host "Starting Script at " $thedate

<# Load the Snapins for VMware #>
$snapins = @("VMware.VimAutomation.Core", "VMware.VimAutomation.Cloud")
foreach ($snapin in $snapins){
  try {
  Write-Host "Trying to load snapin $snapin"
  Add-PSSnapin $snapin -ErrorAction Stop
  Write-Host "$Snapin loaded"
  }
  catch {
  Write-Host "$snapin was already loaded or cannot be loaded"
  }
}

c:
cd 'C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\'
.\Initialize-PowerCLIEnvironment.ps1
d:

write-host "Connecting to " $vcddns " as " $user " .........."
  
<# connect to the vCD Cell server #>
If ($pwd) {  
	connect-ciserver -server $vcddns -org $org -user $user -password $pwd
} else {
    <# prompt user interactively for password #>
	connect-ciserver -server $vcddns -org $org -user 
}

write-host " "
write-host "Getting a List of Orgs"
write-host " "

$vorgvdcs = Get-OrgVdc 

foreach ($orgvdc in $vorgvdcs)
{
    $vapps = Get-CIVApp -orgvdc $orgvdc
    $vappcount = $vapps.count
    write-host "Organisation $orgvdc  has $vappcount vApps"
}

write-host " "

Write-Host "disconnecting " $vcddns
Disconnect-CIServer * -Confirm:$false
Write-Host "Completed"