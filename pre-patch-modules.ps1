#--------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------
# Pre-Patch Modules. Holds all modules required for pre-Patch Scripts...
#--------------------------------------------------------------------------------------------------------------------------------------
write-host ""
write-host "importing Pre-Patch Modules"
write-host " "
#--------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------
#Snapshot VM
function vm-snap($target_vm)
{
        write-host "--------------------------------------------------------------------------------------------------------------------------------------"
        write-host "-Date and time is: $((Get-Date).ToString())"
        Write-Host "Creating a New Snapshot on  $target_vm"
        $target_vm_snapname = ""
        $vm = Get-VM -Name $target_vm 
        $status = $vm.PowerState 
        $priorvmsnapcount = (Get-Snapshot $target_vm).count
        if ($priorvmsnapcount -ne 0) 
        {
            write-host "--------------------------------------------------------------------------------------------------------------------------------------"
            write-host "WARNING: previous Snapshots have been found. Please review the Below. The Pre-Patch Process will continue"
            Get-Snapshot  $target_vm | select VM, Name, Description | ft -AutoSize
        }
        if ($status -eq "PoweredOff")
        {
            try
            {
                $target_vm_snapname =  "Prior_to_OS_Patch " + "{0:D}" -f (get-date)
                $target_vm_snapdesc = "Created by first patch cycle script on " + "{0:D}" -f (get-date) 

                new-Snapshot $target_vm -name $target_vm_snapname -Description  $target_vm_snapdesc -ErrorAction stop | Out-Null
            
               write-host "Checking New Snapshot is good....."
               $check_target_vm_snapname = Get-Snapshot $target_vm | select name  -last 1

               if ($check_target_vm_snapname.name -eq $target_vm_snapname)
               {

                    write-host "--------------------------------------------------------------------------------------------------------------------------------------"
                    write-host "-Date and time is: $((Get-Date).ToString())"
                    Write-Host "Snapshot successfully taken on $target_vm"
                    write-host "--------------------------------------------------------------------------------------------------------------------------------------"
               }
               else
               {
                    $Global:lasterror= "The Last Snapshot does not match the snapshot created by pre-patch prep script"
                    $Global:lasterror_vm = $target_vm
                    write-host "--------------------------------------------------------------------------------------------------------------------------------------"
                    write-host "-Date and time is: $((Get-Date).ToString())"
                    Write-Host "The following error occurred $_"
                    Write-Host "$target_vm could not be snapshotted. Please review"
                    write-host "--------------------------------------------------------------------------------------------------------------------------------------"
               }
           }
           catch
           {
                $Global:lasterror= $_
                $Global:lasterror_vm = $target_vm
                write-host "--------------------------------------------------------------------------------------------------------------------------------------"
                write-host "-Date and time is: $((Get-Date).ToString())"
                Write-Host "The following error occurred $_"
                Write-Host "$target_vm could not be snapshot. Please review"
                write-host "--------------------------------------------------------------------------------------------------------------------------------------"
           }
           
        }
        else
        {
            $Global:lasterror= "The VM $target_vm must be in a powered off state prior to performing the snapshot. $target_vm has not been snapshot"
            $Global:lasterror_vm = $target_vm
            write-host "--------------------------------------------------------------------------------------------------------------------------------------"
            write-host "The VM $target_vm must be in a powered off state prior to performing the snapshot"
            Write-Host "$target_vm has not been snapshotted"
            write-host "--------------------------------------------------------------------------------------------------------------------------------------"
        }

}
#--------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------
# Power off Vm Function
function VM-poweroff ($target_vm)
{
 write-host "--------------------------------------------------------------------------------------------------------------------------------------"
 Write-Output "Shutting down VM $target_vm on vCenter $ManvCenter" 
 
 try
     {
        write-host "-Date and time is: $((Get-Date).ToString())"
        Stop-VMGuest $target_vm -Confirm:$false -ErrorAction Stop | Out-Null
        do { 
                #Wait 5 seconds 
                Start-Sleep -s 5 
                #Check the power status 
                $vm = Get-VM -Name $target_vm 
                $status = $vm.PowerState 

            }until($status -eq "PoweredOff") 
        
        Write-Host "$target_vm has been successfully Shutdown "
        write-host "--------------------------------------------------------------------------------------------------------------------------------------"
     }
     catch
     {
        $vm = Get-VM -Name $target_vm 
        $status = $vm.PowerState 
        $Global:lasterror = $_
        $Global:lasterror_vm = $target_vm
        write-host "--------------------------------------------------------------------------------------------------------------------------------------"
        Write-Host "The following error occurred $_"
        Write-Host "$target_vm is currently $status"
        write-host "--------------------------------------------------------------------------------------------------------------------------------------"
     }
  
}

#--------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------
function VM-poweron  ($target_vm,$target_vm_ip)
{
 write-host "--------------------------------------------------------------------------------------------------------------------------------------"
 write-host "-Date and time is: $((Get-Date).ToString())"
 Write-host "Powering up  $target_vm on vCenter $ManvCenter" 
  try
     {
        Get-VM $target_vm | Start-VM -ErrorAction stop | Out-Null
     }
catch
     {
        write-host "-Date and time is: $((Get-Date).ToString())"
        $vm = Get-VM -Name $target_vm 
        $status = $vm.PowerState 
        $Global:lasterror = $_
        $Global:lasterror_vm = $target_vm
        write-host "--------------------------------------------------------------------------------------------------------------------------------------"
        Write-Host "The following error occurred $_"
        Write-Host "$target_vm is currently $status"
        write-host "--------------------------------------------------------------------------------------------------------------------------------------"
     }

$pingwait = 0
$waitfinished = $false

do 
    {
        #Wait 10 seconds 
        Start-Sleep -s 10
        write-host "--------------------------------------------------------------------------------------------------------------------------------------"
        write-host "Pinging $target_vm on $target_vm_ip....."
        write-host "-Date and time is: $((Get-Date).ToString())"
        write-host "--------------------------------------------------------------------------------------------------------------------------------------"
        $ping = Test-Connection -Cn $target_vm_ip -BufferSize 16 -Count 1 -ea 0 -quiet
        $pingwait = $pingwait + 1

        if ($pingwait -gt 10) {$waitfinished = $true}
        if ($ping) {$waitfinished = $true}
        
    } until ($waitfinished)

if ($ping)
{
    Write-Host "$target_vm has successfully Powered On and is pingable"
    write-host "***** Pre Patch Preparation has been successfully completed on $target_vm ****"
    write-host "--------------------------------------------------------------------------------------------------------------------------------------"
}
else
{
    Write-Host "Exceeded Ping Wait time. $target_vm is still Not pingable. waited $pingwait pings"
    write-host "--------------------------------------------------------------------------------------------------------------------------------------"
    $Global:lasterror = "Exceeded Ping Wait time. $target_vm is still Not pingable. waited $pingwait pings"
    $Global:lasterror_vm = $target_vm

}

}