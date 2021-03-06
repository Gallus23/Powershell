#--------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------
# Pre-Patch First Cycle : Script will shutdown, Snpshot and Power on the  WCS, RMQ, VUM, VCDFIL1 and SPINITFIL1 servers of a site specified as a parameter
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
if ($Location -eq "")
{
     Write-Host "-Location Parameter required"
     exit
}

write-host "--------------------------------------------------------------------------------------------------------------------------------------"
write-host "Starting Pre-Patch Preparation"
write-host "This Script will shutdown and snapshot the RMQ, VUM, SPINITFIL,  WCS, VCDFIL components of myStack"
write-host "--------------------------------------------------------------------------------------------------------------------------------------"

add-pssnapin -name VMware.VimAutomation.Core

#--------------------------------------------------------------------------------------------------------------------------------------
# Call Powercli Modules required
# VM-poweroff
# VM-poweron
# vm-snap
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
    "lo1" {$ManvCenter = "lo1wpcorevcs01.dcsprod.dcsroot.local"}
#    "icd" {$ManvCenter = "icdwpcorevcs41.dcsprod.dcsroot.local"}
#    "nj2" {$ManvCenter = "nj2wpcorevcs41.dcsprod.dcsroot.local"}
    "bz1" {$ManvCenter = "bz1wpcorevcs41.dcsprod.dcsroot.local"}
    "sg8" {$ManvCenter = "sg8wpcorevcs01.dcsprod.dcsroot.local"}
    "sh1" {$ManvCenter = "sh1wpcorevcs01.dcsprod.dcsroot.local"}
    "bj1" {$ManvCenter = "bj1wpcorevcs01.dcsprod.dcsroot.local"}
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
#First Patch Cycle to shutdown and snapshot the following VM's
#RMQ, VUM, SPINITFIL,  WCS, VCDFIL
#
#set vars for all affected VM's

$rmq = $Location + "w" + $srvprefix + "vcdrmq002"
$rmq_ip = $rmq + ".dcsprod.dcsroot.local"

$vum = $Location + "w" + $srvprefix + "vcdvum002"
$vum_ip = $vum + ".dcsprod.dcsroot.local"

$spinitfil = $Location + "wpspinitfil1"
$spinitfil_ip = $spinitfil + ".dcsprod.dcsroot.local"

$wcs = $Location + "w" + $srvprefix + "vcdwcs002"
$wcs_ip = $wcs + ".dcsprod.dcsroot.local"

$vcdfil = $Location + "u" + $srvprefix + "vcdfil001"
$vcdfil_ip = $vcdfil + ".pearsontc.com"

#Send email to mystack-Ops to inform them of start of process
send-mailmessage -to "mystack-operations@pearson.com" -from "mystack.ospatching@pearson.com" -subject "$location $srvprefix - Starting of Cycle 1 Pre-Patch-Prep"  -body "The servers $rmq, $vum, $wcs, $spinitfil, $vcdfil will be shutdown, snapshotted and powered back on prior to having O/S patches applied with BSA. More info on https://mycloud.atlassian.net/wiki/pages/viewpage.action?pageId=37486766 full log on \\LO1WPVCDOPS002.DCSPROD.DCSROOT.LOCAL\log\$location-Pre_Patch_1st_cycle.txt" -smtpServer relay.mx.pearson.com


#RMQ
    if ($Global:lasterror -eq "None")
    {
        write-host "Starting pre patch prep on $rmq"
        #Power off the VM
        VM-poweroff $rmq
    }
    if ($Global:lasterror -eq "None")
    {
        #Take a snapshot
        vm-snap $rmq
    }    

    if ($Global:lasterror -eq "None")
    {
        #Power the VM back on
        vm-poweron $rmq $rmq_ip
    }
    
#VUM
    if ($Global:lasterror -eq "None")
    {
        write-host "Starting pre patch prep on $vum"
        #Power off the VM
        VM-poweroff $vum
    }

    if ($Global:lasterror -eq "None")
    {
        #Take a snapshot
        vm-snap $vum
    }

    if ($Global:lasterror -eq "None")
    {
        #Power the Vm back on
        vm-poweron $vum $vum_ip
    }

#WCS
    if ($Global:lasterror -eq "None")
    {
        write-host "Starting pre patch prep on $wcs"
        #Power off the VM
        VM-poweroff $wcs
    }

    if ($Global:lasterror -eq "None")
    {
        #Take a snapshot
        vm-snap $wcs
    }

    if ($Global:lasterror -eq "None")
    {
        #Power the Vm back on
        vm-poweron $wcs $wcs_ip
    }

#vcdfil
    if ($Global:lasterror -eq "None")
    {
        write-host "Starting pre patch prep on $vcdfil"
        #Power off the VM
        VM-poweroff $vcdfil
    }

    if ($Global:lasterror -eq "None")
    {
        #Take a snapshot
        vm-snap $vcdfil
    }

    if ($Global:lasterror -eq "None")
    {
        #Power the Vm back on
        vm-poweron $vcdfil $vcdfil_ip
    }

#spinitfil

if ($srvprefix -ne "r")
{
    if ($Global:lasterror -eq "None")
    {
        #Power off the VM
        VM-poweroff $spinitfil
    }

    if ($Global:lasterror -eq "None")
    {
        #Take a snapshot
        vm-snap $spinitfil
    }

    if ($Global:lasterror -eq "None")
    {
        #Power the Vm back on
        vm-poweron $spinitfil $spinitfil_ip
    }
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

if ($srvprefix -eq "r")
{
    Get-VM $rmq, $vum, $wcs,  $vcdfil -ErrorAction Continue | select Name, powerstate | ft -AutoSize
    Get-Snapshot  $rmq, $vum, $wcs, $vcdfil -ErrorAction Continue | select VM, Name, Description -ErrorAction Continue | ft -AutoSize
}
else
{
    Get-VM $rmq, $vum, $wcs, $spinitfil, $vcdfil -ErrorAction Continue | select Name, powerstate | ft -AutoSize
    Get-Snapshot  $rmq, $vum, $wcs, $spinitfil, $vcdfil -ErrorAction Continue | select VM, Name, Description | sort VM | ft -AutoSize
}

write-host "--------------------------------------------------------------------------------------------------------------------------------------"

#--------------------------------------------------------------------------------------------------------------------------------------
#Disconnect the vCenter
write-host "-Date and time is: $((Get-Date).ToString())"

write-host "Disconnecting vSphere $ManvCenter......."
disconnect-viserver -server $ManvCenter -Confirm:$false -force
#--------------------------------------------------------------------------------------------------------------------------------------
send-mailmessage -to "mystack-operations@pearson.com" -from "mystack.ospatching@pearson.com" -subject "$location $srvprefix - Completion of Cycle 1 Pre-Patch-Prep"  -body "The servers $rmq, $vum, $wcs, $spinitfil, $vcdfil have been shutdown, snapshotted and powered back on prior to having O/S patches applied with BSA. More info on https://mycloud.atlassian.net/wiki/pages/viewpage.action?pageId=37486766 full log on \\LO1WPVCDOPS002.DCSPROD.DCSROOT.LOCAL\log\$location-Pre_Patch_1st_cycle.txt" -smtpServer relay.mx.pearson.com
write-host "Sleeping before emailing environment check to mystack ops"
sleep 3600
send-mailmessage -to "mystack-operations@pearson.com" -from "mystack.ospatching@pearson.com" -subject "$location $srvprefix - O/S Patch completion (estimate)"  -body "The servers $rmq, $vum, $wcs, $spinitfil, $vcdfil Should now have been patched. Verify and confirm operation. More info on https://mycloud.atlassian.net/wiki/pages/viewpage.action?pageId=37486766" -smtpServer relay.mx.pearson.com
#--------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------




