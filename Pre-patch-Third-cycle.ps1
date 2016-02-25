#--------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------
# Pre-Patch Third Cycle : Script will shutdown, Snapshot and Power on the VCD Cell Servers VCDVCD001 and VCDVCD002 on a site specified as a parameter to the script.
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
write-host "This Script will shutdown and snapshot the VCD components of myStack"
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
    Connect-VIServer -Server  $ManvCenter -ErrorAction Stop | Out-Null
}
catch 
{
    Write-Host "failed to connect to vCenter. Error is $_"
    $Global:lasterror = $_
}

#--------------------------------------------------------------------------------------------------------------------------------------
#Thord Patch Cycle to shutdown and snapshot the following VM's
# VCD001, VCD002
#
#set vars for all affected VM's

$vcdvcdone = $Location + "u" + $srvprefix + "vcdvcd001"
$vcdvcdone_ip = $vcdvcdone + ".pearsontc.com"

$vcdvcdtwo = $Location + "u" + $srvprefix + "vcdvcd002"
$vcdvcdtwo_ip = $vcdvcdtwo + ".pearsontc.com"

#vcdvcdone
    if ($Global:lasterror -eq "None")
    {
        write-host "Starting pre patch prep on $vcdvcdone"
        #Power off the VM
        VM-poweroff $vcdvcdone
    }

    if ($Global:lasterror -eq "None")
    {
        #Take a snapshot
        vm-snap $vcdvcdone
    }

    if ($Global:lasterror -eq "None")
    {
        #Power the Vm back on
        vm-poweron $vcdvcdone $vcdvcdone_ip
    }

#vcdvcdtwo
    if ($Global:lasterror -eq "None")
    {
        write-host "Starting pre patch prep on $vcdvcdtwo"
        #Power off the VM
        VM-poweroff $vcdvcdtwo
    }

    if ($Global:lasterror -eq "None")
    {
        #Take a snapshot
        vm-snap $vcdvcdtwo
    }

    if ($Global:lasterror -eq "None")
    {
        #Power the Vm back on
        vm-poweron $vcdvcdtwo $vcdvcdtwo_ip
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
    
    Get-VM $vcdvcdone, $vcdvcdtwo -ErrorAction Continue | select Name, powerstate | ft -AutoSize
    Get-Snapshot  $vcdvcdone, $vcdvcdtwo -ErrorAction Continue | select VM, Name, Description | sort VM | ft -AutoSize


write-host "--------------------------------------------------------------------------------------------------------------------------------------"

#--------------------------------------------------------------------------------------------------------------------------------------
#Disconnect the vCenter
write-host "-Date and time is: $((Get-Date).ToString())"

write-host "Disconnecting vSphere $ManvCenter......."
disconnect-viserver -server $ManvCenter -Confirm:$false -force
#--------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------
send-mailmessage -to "Mike Howard <mike.howard@pearson.com>" -from "mystack.ospatching@pearson.com" -subject "$location - Completion of Cycle 3 Pre-Patch-Prep, log attached"  -body "The servers $vcdvcdone, $vcdvcdtwo  have been shutdown, snapshotted and powered back on prior to having O/S patches applied with BSA. More info on https://mycloud.atlassian.net/wiki/pages/viewpage.action?pageId=37486766" -smtpServer relay.mx.pearson.com
#--------------------------------------------------------------------------------------------------------------------------------------

sleep 3600
send-mailmessage -to "Mike Howard <mike.howard@pearson.com>" -from "mystack.ospatching@pearson.com" -subject "$location - O/S Patch completion (estimate)"  -body "The servers $vcdvcdone, $vcdvcdtwo Should now have been patched. Verify and confirm operation. More info on https://mycloud.atlassian.net/wiki/pages/viewpage.action?pageId=37486766" -smtpServer relay.mx.pearson.com



