#--------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------
# Pre-Patch Second Cycle : Script will shutdown, Snpshot and Power on the SSO, and VCS  on a site specified as a paramter to the script
#--------------------------------------------------------------------------------------------------------------------------------------
#Variable declaration
param(
	[string]$Location
	)
$srvprefix = "p"
$Global:lasterror = "None"
$Global:lasterror_vm = "None"

#--------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------
#Main Script
if ($Location -eq "")
{
     Write-Host "-Location Parameter required"
     exit
}

write-host "--------------------------------------------------------------------------------------------------------------------------------------"
write-host "Starting Pre-Patch Preparation"
write-host "This Script will shutdown and snapshot the SSO and VCS components of myStack"
write-host "--------------------------------------------------------------------------------------------------------------------------------------"

add-pssnapin -name VMware.VimAutomation.Core
#--------------------------------------------------------------------------------------------------------------------------------------
# Call Powercli Functions required
#
. D:\Software\scripts\pre-patch-modules.ps1
#--------------------------------------------------------------------------------------------------------------------------------------


switch ($Location.ToLower())
    {
    "lo3r" {
        $ManvCenter = "lo3wpcorvcs001.dcsprod.dcsroot.local"
        $srvprefix = "r"
        }
     "lo3" {$ManvCenter = "lo3wpcorvcs001.dcsprod.dcsroot.local"}
#    "lo1" {$ManvCenter = "lo1wpcorevcs01.dcsprod.dcsroot.local"}
#    "icd" {$ManvCenter = "icdwpcorevcs41.dcsprod.dcsroot.local"}
#    "nj2" {$ManvCenter = "nj2wpcorevcs41.dcsprod.dcsroot.local"}
    "bz1" {$ManvCenter = "bz1wpcorevcs41.dcsprod.dcsroot.local"}
#    "sg8" {$ManvCenter = "sg8wpcorevcs01.dcsprod.dcsroot.local"}
#    "sh1" {$ManvCenter = "sh1wpcorevcs01.dcsprod.dcsroot.local"}
#    "bj1" {$ManvCenter = "bj1wpcorevcs01.dcsprod.dcsroot.local"}
    "au1" {$ManvCenter = "au1wpcorevcs01.dcsprod.dcsroot.local"}
     }

if ($Location -eq "lo3r")    {    $Location = "lo3"    }

#--------------------------------------------------------------------------------------------------------------------------------------
#Test connection to destination vCenter
write-host "-Date and time is: $((Get-Date).ToString())"

Write-Host "Testing Connection to vCenter $ManvCenter" -foregroundcolor "magenta" 
if(!(Test-Connection -Cn $ManvCenter -BufferSize 16 -Count 1 -ea 0 -quiet))
{
write-host "Connection to $ManvCenter failed cannot ping" -foregroundcolor "red" 
$Global:lasterror = "Connection to $ManvCenter failed cannot ping"
}

#--------------------------------------------------------------------------------------------------------------------------------------
#Connect to vCenter
Write-Host "Connecting to vCenter $ManvCenter" -foregroundcolor "yellow"     

try
{
    Connect-VIServer -Server  $ManvCenter  -ErrorAction Stop | Out-Null
}
catch 
{
    Write-Host "failed to connect to vCenter. Error is $_"
    $Global:lasterror = $_
}

#--------------------------------------------------------------------------------------------------------------------------------------
#Second Patch Cycle to shutdown and snapshot the following VM's
#SSO, VCS
#
#set vars for all affected VM's

$sso = $Location + "w" + $srvprefix + "vcdsso002"
$sso_ip = $sso + ".dcsprod.dcsroot.local"

$vcs = $Location + "w" + $srvprefix + "vcdvcs002"
$vcs_ip = $vcs + ".dcsprod.dcsroot.local"

#SSO
    if ($Global:lasterror -eq "None")
    {
        write-host "Starting pre patch prep on $rmq"
        #Power off the VM
        VM-poweroff $sso
    }
    if ($Global:lasterror -eq "None")
    {
        #Take a snapshot
        vm-snap $sso
    }    

    if ($Global:lasterror -eq "None")
    {
        #Power the VM back on
        vm-poweron $sso $sso_ip
    }
    
#VCS
    if ($Global:lasterror -eq "None")
    {
        write-host "Starting pre patch prep on $vum"
        #Power off the VM
        VM-poweroff $vcs
    }

    if ($Global:lasterror -eq "None")
    {
        #Take a snapshot
        vm-snap $vcs
    }

    if ($Global:lasterror -eq "None")
    {
        #Power the Vm back on
        vm-poweron $vcs $vcs_ip
    }

#--------------------------------------------------------------------------------------------------------------------------------------
#Main Script completed
write-host "--------------------------------------------------------------------------------------------------------------------------------------"
write-host "Pre-Patch Process completed"
write-host "-Date and time is: $((Get-Date).ToString())"

if ($Global:lasterror -ne "None")
{
    write-host "ERROR: The error $Global:lasterror was detected on $Global:lasterror_vm"
}
else
{
    write-host "No Errors found in Pre-Patch Preparation"
}

write-host "--------------------------------------------------------------------------------------------------------------------------------------"
write-host "Environment state is as below." -foregroundcolor "red" 
write-host "--------------------------------------------------------------------------------------------------------------------------------------"
    
write-host "--------------------------------------------------------------------------------------------------------------------------------------"

    Get-VM $vcs, $sso -ErrorAction Continue | select Name, powerstate | ft -AutoSize
    Get-Snapshot  $vcs, $sso   -ErrorAction Continue | select VM, Name, Description -ErrorAction Continue | ft -AutoSize


write-host "--------------------------------------------------------------------------------------------------------------------------------------"

#--------------------------------------------------------------------------------------------------------------------------------------
#Disconnect the vCenter
write-host "-Date and time is: $((Get-Date).ToString())"

write-host "Disconnecting vSphere $ManvCenter......."
disconnect-viserver -server $ManvCenter -Confirm:$false -force
#--------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------




