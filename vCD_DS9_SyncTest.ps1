
#>
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True)]
       [string]$vcddns,

  [Parameter(Mandatory=$True)]
       [string]$org,  

  [Parameter(Mandatory=$True)]
       [string]$orgnet, 
	   
  [Parameter(Mandatory=$True)]
       [string]$catalog, 

  [Parameter(Mandatory=$True)]
       [string]$template, 
  
  [Parameter(Mandatory=$True)]
       [string]$delay,	
	   
  [Parameter(Mandatory=$True)]
       [string]$user,

  [Parameter(Mandatory=$True)]
       [string]$pwd
  )

$thedate = Get-Date
Write-host " "
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

write-host "Connecting to " $vcddns " as " $user " .........."
  
<# connect to the vCD Cell server #>
If ($pwd) {  
	connect-ciserver -server $vcddns -org $org -user $user -password $pwd
} else {
    <# prompt user interactively for password #>
	connect-ciserver -server $vcddns -org $org -user 
}


$vappname =  Get-date -UFormat "%A-%d-%m"

Write-Host "creating vApp " $vappname " in " $org

<#script assumes a single vDC, if this changes, you will need to pass inthe vDC to utilize as an org and add a where-object clause #>
$myorgvdc = get-orgvdc

<# debug code
    echo $("my vdc storage use: " + $myorgvdc.storageusedgb)
	$myvms = get-civm
	$myvms
	$myvapps = get-civapp
	$myvapps
#>

<#get the catalogs the user has access to#> 
echo $("Getting the catalogs available to the user logged in...")
$mycatalogs = get-catalog

<#get the templates from the catalog specified by the user#>
echo $("Getting the templates from the specified catalog...")
$catalogtemplates = $mycatalogs | where-object {$_.name -like $catalog} | get-civapptemplate

<#get the template specified by the user#>
echo $("Getting the template information specified if matched...")
$deploytemplate = $catalogtemplates | where-object {$_.name -eq $template }

<#get the BE and FE networks within the Org #>
echo $("Getting the Org Networks for BE and FE...")
$myBEnetwork = get-orgnetwork | where-object {$_.name -like "BE*"}
$myFEnetwork = get-orgnetwork | where-object {$_.name -like "FE*"}

<#provision the specified template in the org as a new vApp withe specified user name #>
echo $("Deploying the vApp from the template: $template")
$myNewvAPP = new-civapp -name $vappName -description "Created by Powershell DS9/VCD Sync script." -OrgVdc $myorgvdc -vapptemplate $deploytemplate

<#get the network to use for the vAPP as specified by the user param orgnet and add the network specified to the vApp#>
echo $("Creating the specified network in the vApp...")
if ($orgnet -eq "BE") {
	$myNewvAppNetwork = new-civappnetwork -direct -ParentOrgNetwork $myBEnetwork -vApp $myNewvAPP
} else {
	$myNewvAppNetwork = new-civappnetwork -direct -ParentOrgNetwork $myFEnetwork -vApp $myNewvAPP
}

<#get the VM in the newly deloyed vApp - assuming a single VM but this could return multiples #>
echo $("Getting the VM details as deployed in the new vApp...")
$mynewVM = $myNewvApp | Get-CIVM  

<#here is where you would need to consider mulitple VM's per vApp and do a foreach () #>
	<#get the primary NIC of the VM #>
	echo $("   Getting the Primary NIC for the VM...")
	$myNewVMNIC = ($myNewVM | where-object {$_.vapp -eq $mynewvapp}) | get-cinetworkadapter | where-object {$_.Primary}

	<#connect the primary NIC for the VM to the vAPP network and get the IP address assigned from the pool #>
	echo $("   Connecting the VM's primary NIC to the specified vAPP network...")
	$mynewvmIP = (set-cinetworkadapter -networkadapter $mynewvmnic -vappnetwork $myNewvappnetwork -ipaddressallocationmode Pool -connected $True) | select IPaddress
	<#check to see $mynewvmIP is not blank #>
<#end foreach()#>

Write-Host "disconnecting " $vcddns
Disconnect-CIServer * -Confirm:$false
Write-Host "Completed"