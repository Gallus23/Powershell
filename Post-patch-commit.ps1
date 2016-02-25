#--------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------
# Post Patch Commit.. Script will Delete the Pre-Patch Snapshots taken as roll back prior to OS Patching...
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
#--------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------
#Main Script - Post Patch Commit
if ($Location -eq "")
{
     Write-Host "-Location Parameter required, please."
     exit
}

write-host "--------------------------------------------------------------------------------------------------------------------------------------"
write-host "Starting Post-Patch Housekeeping"
write-host "Post Patch Commit.. Script will Delete the Pre-Patch Snapshots taken as roll back prior to OS Patching..."
write-host "--------------------------------------------------------------------------------------------------------------------------------------"

add-pssnapin -name VMware.VimAutomation.Core

#Connect to relevant vCenter
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
#Post Patch Commit of changes, deletion of pre patch snapshots
#VCD002
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

$sso = $Location + "w" + $srvprefix + "vcdsso002"
$sso_ip = $sso + ".dcsprod.dcsroot.local"

$vcs = $Location + "w" + $srvprefix + "vcdvcs002"
$vcs_ip = $vcs + ".dcsprod.dcsroot.local"

$vcdvcdone = $Location + "u" + $srvprefix + "vcdvcd001"
$vcdvcdone_ip = $vcdvcdone + ".pearsontc.com"

$vcdvcdtwo = $Location + "u" + $srvprefix + "vcdvcd002"
$vcdvcdtwo_ip = $vcdvcdtwo + ".pearsontc.com"

$sso = $Location + "w" + $srvprefix + "vcdsso002"
$sso_ip = $sso + ".dcsprod.dcsroot.local"

$vcs = $Location + "w" + $srvprefix + "vcdvcs002"
$vcs_ip = $vcs + ".dcsprod.dcsroot.local"

$vcdvcdone = $Location + "u" + $srvprefix + "vcdvcd001"
$vcdvcdone_ip = $vcdvcdone + ".pearsontc.com"

$vcdvcdtwo = $Location + "u" + $srvprefix + "vcdvcd002"
$vcdvcdtwo_ip = $vcdvcdtwo + ".pearsontc.com"


write-host "Listing all current Snapshots"

$snaps = get-vm  $rmq, $vum, $wcs, $vcdfil, $sso, $vcs, $vcdvcdone -ErrorAction Continue | get-snapshot  | where {$_.name -match  "Prior_to_OS_Patch"}  | select VM, Name, description


        if ($snaps.Count -eq 0)
        {
        Write-Host "No Pre-Patch Snapshots found"
        }
    else
        {
        write-host "--------------------------------------------------------------------------------------------------------------------------------------"
        write-host "Listing Snapshots"
        write-host " "
        write-host $snaps
        write-host "--------------------------------------------------------------------------------------------------------------------------------------"
        write-host "Removing Snapshots ....."

            foreach ($snap in $snaps)
            {
                try
                {

                    write-host "Date and time is: $((Get-Date).ToString())"
                    write-host "Starting snapshot removal on $snap "
                    Get-VM $snap.vm |  get-snapshot  | where {$_.name -match  "Prior_to_OS_Patch"} | Remove-Snapshot -Confirm:$false
                    write-host "Compeleted"
                }
            catch
                {
                        write-host "--------------------------------------------------------------------------------------------------------------------------------------"
                        write-host "-Date and time is: $((Get-Date).ToString())"
                        Write-Host "The following error occurred $_"
                        write-host "--------------------------------------------------------------------------------------------------------------------------------------"
                }
            }
        }

write-host "Script completed"
write-host "--------------------------------------------------------------------------------------------------------------------------------------"
write-host "Snapshots at end of process... there should be none listed"

$snaps = get-vm  $rmq, $vum, $wcs, $vcdfil, $sso, $vcs, $vcdvcdone -ErrorAction Continue | get-snapshot  | where {$_.name -match  "Prior_to_OS_Patch"}  | select VM, Name, description

if ($snaps.Count -eq 0)
{
Write-Host "No Pre-Patch Snapshots found"
}
else
{
write-host "Listing Snapshots"
write-host " "
write-host $snaps
}

write-host "--------------------------------------------------------------------------------------------------------------------------------------"
#--------------------------------------------------------------------------------------------------------------------------------------
#Disconnect the vCenter
write-host "-Date and time is: $((Get-Date).ToString())"

write-host "Disconnecting vSphere $ManvCenter......."
disconnect-viserver -server $ManvCenter -Confirm:$false -force
#--------------------------------------------------------------------------------------------------------------------------------------
send-mailmessage -to "Mike Howard <mike.howard@pearson.com>" -from "mystack.ospatching@pearson.com" -subject "$location - Completion of Post Patch commit, log attached" -body "Pre O/S patch Snapshots on $rmq, $vum, $wcs, $vcdfil, $sso, $vcs, $vcdvcdone should now have been deleted, commiting O/S patches. More info on https://mycloud.atlassian.net/wiki/pages/viewpage.action?pageId=37486766" -smtpServer relay.mx.pearson.com