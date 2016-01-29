#--------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------
# Post-Patch-Email to mystack-operations to list any outstanding snapshots required for removal.
#--------------------------------------------------------------------------------------------------------------------------------------
#Variable declaration

$Global:lasterror = "None"
$outfile = "D:\Software\Scripts\CSV-Files\Patch-Snapshot-list.txt"

#--------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------
#Main Script

add-content $outfile "--------------------------------------------------------------------------------------------------------------------------------------"
add-content $outfile "This Script will list all remaining snapshots created by the pre-patch process."
add-content $outfile "--------------------------------------------------------------------------------------------------------------------------------------"

add-pssnapin -name VMware.VimAutomation.Core


#--------------------------------------------------------------------------------------------------------------------------------------
#Main Script
#--------------------------------------------------------------------------------------------------------------------------------------
#Array of vCenters
$vCenters = @(
    "lo3wpcorvcs001.dcsprod.dcsroot.local",
    "lo1wpcorevcs01.dcsprod.dcsroot.local"
#    "icdwpcorevcs41.dcsprod.dcsroot.local",
#    "nj2wpcorevcs41.dcsprod.dcsroot.local",
#    "bz1wpcorevcs41.dcsprod.dcsroot.local",
#    "sg8wpcorevcs01.dcsprod.dcsroot.local",
#    "sh1wpcorevcs01.dcsprod.dcsroot.local",
#    "bj1wpcorevcs01.dcsprod.dcsroot.local",
#    "au1wpcorevcs01.dcsprod.dcsroot.local"
);

#Delete the old Outputfile
Remove-Item D:\Software\Scripts\CSV-Files\Patch-Snapshot-list.txt

 ForEach ($vCenter in $vCenters)
{

        #Test connection to destination vCenter
        add-content $outfile "-Date and time is: $((Get-Date).ToString())"

        add-content $outfile "Testing Connection to vCenter $vCenter" 
        if(!(Test-Connection -Cn $vCenter -BufferSize 16 -Count 1 -ea 0 -quiet))
        {
            add-content $outfile "Connection to $vCenter failed cannot ping"
            $Global:lasterror = "Connection to $vCenter failed cannot ping"
        }

        
        #Connect to vCenter
        if ($Global:lasterror -eq "None")
        {
               add-content $outfile "Connecting to vCenter $vCenter"      
               try
                {
                    Connect-VIServer -Server  $vCenter -ErrorAction Stop | Out-Null

                }
                catch 
                {
                    add-content $outfile "failed to connect to vCenter. Error is $_"
                    $Global:lasterror = $_
                }
                add-content $outfile " "

                if ((get-vm  *rvcd*, *pvcd*, *spinitfil1 -ErrorAction Continue | get-snapshot  | where {$_.name -match  “Prior_to_OS_Patch*”}).count -gt 0)
                {
                    add-content $outfile "Listing all current Snapshots in  $vCenter "
                    get-vm  *rvcd*, *pvcd*, *spinitfil1 -ErrorAction Continue | get-snapshot  | where {$_.name -match  “Prior_to_OS_Patch*”}  | select VM, Name, description  | format-table -auto | out-file $outfile -Append -Encoding ASCII
                }
                else
                {
                    add-content $outfile "No outstanding snapshots in  $vCenter"
                }
                add-content $outfile " "

                #Disconnect the vCenter
                add-content $outfile "-Date and time is: $((Get-Date).ToString())"
                add-content $outfile "Disconnecting vSphere $vCenter......."
                disconnect-viserver -server $vCenter -Confirm:$false -force
                add-content $outfile "--------------------------------------------------------------------------------------------------------------------------------------"
              
       }

       
       
}

Send-MailMessage -SmtpServer relay.mx.pearson.com -Subject "List of outstanding Snapshots resulting from Patching" -Attachments $outfile -Body "See Attached" -To mike.howard@pearson.com -From mystack-operations@pearson.com

#--------------------------------------------------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------




