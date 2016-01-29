param(
    [string]$vcenter = "bz1wpcorevcs41.dcsprod.dcsroot.local",
    [int]$last = 24,
    [switch]$help = $false
)
 
$maxevents = 250000

$temp = get-date
$stop = $temp
$start = $temp - (New-TimeSpan -hours 4)

if (!(get-pssnapin -name "VMware.VimAutomation.Core" -ErrorAction SilentlyContinue )) { add-pssnapin "VMware.VimAutomation.Core" }
 
write-host "`nConnecting to vCenter server $vcenter ..."
Connect-VIServer $vcenter | out-null
 
write-host "`nGetting all events from $start to $stop (max. $maxevents) ..."
$events = Get-VIEvent -Start $start -Finish $stop -MaxSamples $maxevents
 
write-host Got $events.Length events ...
 
write-host -nonewline "`nSearching for host failure events ..."
$ha = @()
$events | where-object { $_.EventTypeID -eq "com.vmware.vc.HA.DasHostFailedEvent" } | foreach { $ha += $_ }
write-host (" found " + $ha.Length + " event(s).")
if ($ha.Length -eq 0) {
    write-host "`nNo host failure events found in the last $last hours."
    write-host "Use parameter -last to specify number of hours to look back.`n"
    exit
} else {
    write-host ("`nLatest host failure event was " + $ha[0].ObjectName + " at " + $ha[0].CreatedTime + ".")
    write-host ("`nLatest host failure event was " + $ha[1].ObjectName + " at " + $ha[1].CreatedTime + ".")
    write-host ("`nLatest host failure event was " + $ha[2].ObjectName + " at " + $ha[2].CreatedTime + ".")
    write-host ("`nLatest host failure event was " + $ha[3].ObjectName + " at " + $ha[3].CreatedTime + ".")
}
 
$events = $events | where-object { $_.CreatedTime -ge $ha[3].CreatedTime }
 
write-host "`nList of successful VM restarts:"
$events | where-object { $_.EventTypeID -eq "com.vmware.vc.ha.VmRestartedByHAEvent" } | foreach {
    write-host $_.CreatedTime: $_.ObjectName
}
 
write-host "`nList of failed VM restarts:"
$failures = @{}
$events | where-object { $_.FullFormattedMessage -like "vSphere HA stopped trying*" } | foreach {
    $vmname = $_.FullFormattedMessage.Split(" ")[6]
    if (!($failures.ContainsKey($vmname))) {
        $failures.Add($vmname,$_.CreatedTime)
        write-host $_.CreatedTime: $vmname
    }
}
 
Disconnect-VIServer -Force -Confirm:$false
