Param(
  [Parameter(Mandatory=$True)]
       [string]$vcddns,

  [Parameter(Mandatory=$True)]
       [string]$org,  
	   
  [Parameter(Mandatory=$True)]
       [string]$user,

  [Parameter(Mandatory=$True)]
       [string]$pwd
  )
  
  $ConfirmPreference = 'None'

  <# Load the Snapins for VMware #>

Write-host " "
Write-Host "Starting Script $((Get-Date).ToString())"
write-host "--------------------------------------------------------------------------------------------------------------------------------------"
write-host "Loading CORE and CLOUD plugins for powershell"
c:
cd 'C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\'

.\Initialize-PowerCLIEnvironment.ps1
write-host "--------------------------------------------------------------------------------------------------------------------------------------"

d:
cd D:\Software\Scripts

write-host "Connecting to " $vcddns " as " $user " .........."

<# connect to the vCD Cell server #>
If ($pwd) {  
	connect-ciserver -server $vcddns -org $org -user $user -password $pwd
} else {
    <# prompt user interactively for password #>
	connect-ciserver -server $vcddns -org $org -user 
}

$vappname =  Get-date -UFormat "%A-%d-%m"

<#stop teh vApp and delete it#>
echo $("Stopping the vApp's below and the deleting them...")
get-CIVApp | where {$_.owner -like 'ds9_sync_test' } | select name, owner

#old version
#get-CIVApp | where {$_.name -eq $vappname } | Stop-CIVApp -ErrorAction SilentlyContinue
#get-CIVApp | where {$_.name -eq $vappname } | remove-civapp -confirm:$false

get-CIVApp | where {$_.owner -like 'ds9_sync_test' } | Stop-CIVApp -ErrorAction SilentlyContinue -confirm:$false
get-CIVApp | where {$_.owner -like 'ds9_sync_test' } | remove-civapp -confirm:$false

write-host "Completed $((Get-Date).ToString())"
Disconnect-CIServer * -Confirm:$false





