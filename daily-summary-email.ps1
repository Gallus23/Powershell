#--------------------------------------------------------------------------------------------------------------------------------------
#This script converts the csv files created by the scheduled rvTools exports into a user friendly html which is saved to a local website
#--------------------------------------------------------------------------------------------------------------------------------------
#check we know which site we're checking....
Param
(
  [Parameter(Mandatory=$True)]
       [string]$location  
)
switch ($location.ToLower())
{
    "hamburg-office"         { $vCenter = "hhov-vcsa02.mare.esailors.net"}
    "hamburg-datacenter"     { $vCenter = "vm-vcsa-04-hh1.t24de.tipp24.net"}
    "london-location-cd"      { $vCenter = "lndv-vcsa02c.games-int.net"}
    "london-office"          { $vCenter = "lnov-vcsa01.games-int.net"}
    "madrid-office"          { $vCenter = "mdov-vcsa03.games-int.net"}
    "london-location-c-nsx"  { $vCenter = "vcsa10-c.games-int.net" }
 }
 
#define the logfile name and clear old files
$verboseLogFile = "F:\Scripts\_Production\daily-summary\" + $vcenter + ".log"
new-Item $verboseLogFile -type File -force

Function My-Logger {
    param(
    [Parameter(Mandatory=$true)]
    [String]$message
    )

    $timeStamp = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"

    Write-Host -NoNewline -ForegroundColor White "[$timestamp]"
    Write-Host -ForegroundColor Green " $message"
    $logMessage = "[$timeStamp] $message"
    $logMessage | Out-File -Append -LiteralPath $verboseLogFile
}

My-Logger "switching to location $location and vcenter $vcenter"

#Initalize Powercli....
if (! (Get-Module -Name VMware*) )
{
    My-Logger "Loading VMWare powercli...."
    cd 'C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\'
    .\Initialize-PowerCLIEnvironment.ps1
    cd F:\Scripts\_Production\daily-summary
}

#Import the module for Fancy html tables
My-Logger "Loading convert to advhtml module"
import-module F:\Scripts\Modules\ConvertTo-AdvHTML.psm1
my-logger "Loading Modules for powershell graphs"
import-module F:\Scripts\Modules\Create-Chart.ps1
import-module F:\Scripts\Modules\Create-HashTable.ps1

my-logger "Removing old graphs"
remove-item "images\memorystats-$location.png" -Force
remove-item "images\vcpustats-$location.png" -Force
remove-item "images\powerstats-$location.png" -Force


my-logger "Setting general variables"
#General variables
    $BasePath = "F:\Share\_Inventory_Information\Exports\" + $vcenter + "\"
    $Date = (Get-Date -f "yyyyMMdd")
    $smtpServer = "10.44.35.130"
   
#HMTL formatting variables    
    $PageBoxOpener="<div id='box1'>"
    $BoxContentOpener="<div id='boxcontent'>"
    $PageBoxCloser="</div>"
    $br="<br>" 

#Connect to vCenter    
my-logger "connecting to vcenter"
Connect-viserver $vcenter
#----------------------------------------------------------------------------------------------------------------------
#This is the CSS used to add the style to the report
My-Logger "Setting ccs for report"
$Css="<style>
body {
    font-family: Verdana, sans-serif;
    font-size: 14px;
	color: #666666;
	background: #FEFEFE;
}
#title{
	color:#10259C;
	font-size: 30px;
	font-weight: bold;
	padding-top:25px;
	margin-left:35px;
	height: 50px;
}
#subtitle{
	font-size: 11px;
	margin-left:35px;
}
#main {
	position:relative;
	padding-top:10px;
	padding-left:10px;
	padding-bottom:10px;
	padding-right:10px;
}
#box1{
	position:absolute;
	background: #F8F8F8;
	border: 1px solid #DCDCDC;
	margin-left:10px;
	padding-top:10px;
	padding-left:10px;
	padding-bottom:10px;
	padding-right:10px;
}
#boxheader{
	font-family: Arial, sans-serif;
	padding: 5px 20px;
	position: relative;
	z-index: 20;
	display: block;
	height: 30px;
	color: #777;
	
	line-height: 33px;
	font-size: 19px;
	background: #fff;
	background: -moz-linear-gradient(top, #ffffff 1%, #eaeaea 100%);
	background: -webkit-gradient(linear, left top, left bottom, color-stop(1%,#ffffff), color-stop(100%,#eaeaea));
	background: -webkit-linear-gradient(top, #ffffff 1%,#eaeaea 100%);
	background: -o-linear-gradient(top, #ffffff 1%,#eaeaea 100%);
	background: -ms-linear-gradient(top, #ffffff 1%,#eaeaea 100%);
	background: linear-gradient(top, #ffffff 1%,#eaeaea 100%);
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#ffffff', endColorstr='#eaeaea',GradientType=0 );
	box-shadow: 
		0px 0px 0px 1px rgba(155,155,155,0.3), 
		1px 0px 0px 0px rgba(255,255,255,0.9) inset, 
		0px 2px 2px rgba(0,0,0,0.1);
}
table{
	width:100%;
	border-collapse:collapse;
}
table td, table th {
	border:1px solid #000;
	padding:3px 7px 2px 7px;
}
table th {
	text-align:left;
	padding-top:5px;
	padding-bottom:4px;
	background-color:#10259C;
color:#fff;
}
table tr.alt td {
	color:#000;
	background-color:#EAF2D3;
}
</style>"


#----------------------------------------------------------------------------------------------------------------------
#Report Intro
#This is the javascript used to dectect warnings and erros and colour the cells appropriately.
my-logger "Defining report header"
$intro =  "<p style='text-align:center'><img src='SMARTGAMESTECH_LOGO_HORIZONTAL_MINI.jpg'>$br<div id='title'></a><p style='text-align:center'>Daily Summary Report for : $location</div><div id='small'><p style='text-align:center'>Report generated: $(Get-Date)</div>"
#----------------------------------------------------------------------------------------------------------------------
#Check the datafile exisits
my-logger "Working on VM Graphs"
   
    #Check the datafile exisits
    $datafile = $BasePath  + $Date + "\" + "RVTools_tabvInfo.csv"
    my-logger "checking for $datafile"
    if ( Test-Path ($datafile) )
    {     
        my-logger "Getting Powerstats"
        $powered_on_VMs = (Import-Csv $datafile | where { $_.Powerstate -eq "poweredOn"} ).count
        $powered_off_VMs = (Import-Csv $datafile | where { $_.Powerstate -eq "poweredOff"} ).count

        my-logger "Getting vCPU stats"
        $single_vcpu = (Import-Csv $datafile | where { [int]$_.CPUs -eq 1} ).count
        $dual_vcpu = (Import-Csv $datafile | where { [int]$_.CPUs -eq 2} ).count
        $lt_quad_vcpu = (Import-Csv $datafile | where { [int]$_.CPUs -eq 3 -or [int]$_.CPUs -eq 4} ).count
        $lt_eight_vcpu = (Import-Csv $datafile | where { [int]$_.CPUs -gt 3 -and [int]$_.CPUs -lt 9} ).count
        $gt_eight_vcpu = (Import-Csv $datafile | where { [int]$_.CPUs -gt 8 } ).count

        my-logger "Getting RAM stats"
        $lt_fourgb_ram  = (Import-Csv $datafile | where { [int]$_.memory -lt 4097} ).count
        $lt_eightgb_ram  = (Import-Csv $datafile | where { [int]$_.memory -gt 4097 -and [int]$_.memory -lt 8193 } ).count
        $lt_sixteengb_ram = (Import-Csv $datafile | where { [int]$_.memory -gt 8192 -and [int]$_.memory -lt 16000 } ).count
        $gt_sixteengb_ram = (Import-Csv $datafile | where { [int]$_.memory -gt 16000 } ).count

        $Power_stats = @{}
        $Power_stats.add("Powered Off" ,$powered_off_VMs)
        $Power_stats.add("Powered On", $powered_on_VMs)

        $cpu_stats = @{}
        $cpu_stats.add("1 vCPU" ,$single_vcpu)
        $cpu_stats.add("2 vCPU" ,$dual_vcpu)
        $cpu_stats.add("3-4 vCPU" ,$lt_quad_vcpu)
        $cpu_stats.add("4-8 vCPU" ,$lt_eight_vcpu)
        $cpu_stats.add("+8 vCPU" ,$gt_eight_vcpu)

        $memory_stats = @{}
        $memory_stats.add("0Gb-4Gb RAM", $lt_fourgb_ram)
        $memory_stats.add("4Gb-8Gb RAM", $lt_eightgb_ram)
        $memory_stats.add("8Gb-16Gb RAM", $lt_sixteengb_ram)
        $memory_stats.add("+16b RAM", $gt_sixteengb_ram)

        my-logger "Creating Graphs"
        Create-Chart -ChartType pie -ChartTitle "VM Power Stats" -FileName images\Powerstats-$location -XAxisName "Powerstate" -YAxisName "Quantity" -ChartWidth 450 -ChartHeight 350 -DataHashTable $Power_stats
        Create-Chart -ChartType pie -ChartTitle "VM vCPU Stats" -FileName images\vcpustats-$location -XAxisName "vCPU's" -YAxisName "Quantity" -ChartWidth 450 -ChartHeight 350 -DataHashTable $cpu_stats
        Create-Chart -ChartType pie -ChartTitle "VM Memory Stats" -FileName images\memorystats-$location -XAxisName "RAM" -YAxisName "Quantity" -ChartWidth 450 -ChartHeight 350 -DataHashTable $memory_stats
    }

    $report_graphs = "$br<center><img src='Powerstats-$location.png'><img src='vcpustats-$location.png'><img src='memorystats-$location.png'></center>$br"

#----------------------------------------------------------------------------------------------------------------------
#List Open Snapshots 
my-logger "working on snapshot list"
$report_snapshots ="<div id='boxheader'>Open Snapshot List</div>"
$mycsv_snapshots = @()
$servers_snap = $servers
   
    #Check the datafile exisits
    $datafile = $BasePath  + $Date + "\" + "RVTools_tabvSnapshot.csv"
    my-logger "checking for $datafile"
    if ( Test-Path ($datafile) )
    {          
      my-logger "file exists pulling snapshot info"
       $mycsv_snapshots += import-csv $datafile | Select-Object vm,cluster,name,description,@{name="Creation";Expression={  $_."date / time" }} | sort-object creation
    }

#Convert resultant array to html table for addition to report. 
my-logger "converting snapshot data to html format"
$mycsv_snapshots = $mycsv_snapshots | ConvertTo-Html -Title "Snapshot List" -PostContent "<br>Done! $(Get-Date)"
#----------------------------------------------------------------------------------------------------------------------
#Cluster Summary
my-logger "working on cluster high level summary"
$report_summary ="<div id='boxheader'>Cluster High level Summary</div>"

    #Check the datafile exisits
    $datafile = $BasePath + "\"  + $Date + "\" + "RVTools_tabvCluster.csv"
    if ( Test-Path ($datafile) )
    {          
      
       $mycsv_cluster = import-csv $datafile | select name,overallstatus,numHosts,@{name="CPU capacity (Ghz)";Expression={ "{0:N2}" -f ($_."Effective Cpu" / 1000)}},@{name="Logical CPU's";Expression={  $_.NumCpuThreads }},@{name="Memory Capacity (Gb)";Expression={ "{0:N0}" -f ($_."Effective Memory" / 1024) }} | ConvertTo-Html -Fragment

    }

#----------------------------------------------------------------------------------------------------------------------
#List Low capcity Datastores
my-logger "working on datastore information"
$report_datastores ="<div id='boxheader'>Datastore Information</div>"
   
#Set Alarm and warning levels
$datastore_warn_Level = 30
$datastore_alarm_level = 10

#Check the datafile exisits
$datafile = $BasePath + $Date + "\" + "RVTools_tabvDatastore.csv"
if ( Test-Path ($datafile) )
{          
    $mycsv_datastores = import-csv $datafile | select-object name,@{name="Capacity GB";Expression={ "{0:N0}" -f ((($_."Capacity MB" -as [int]) / 1024) -as [int])}}, @{name="Free GB";Expression={ "{0:N0}" -f ((($_."Free MB" -as [int])/ 1024) -as [int])}}| sort-object "Free GB" 
    $mycsv_datastores | Add-Member -Type NoteProperty -name Status -Value  "Good"
    $mycsv_datastores | Add-Member -Type NoteProperty -name "Free Percent" -Value  " "

    #Now add Alarm levels
    foreach ($ds in $mycsv_datastores)
    {
        [int]$ds."Free Percent" = ($ds.'Free GB' / $ds.'Capacity GB') * 100

        $ds.status =  "[image:20;20;tick.jpg]" 
        if ([int]$ds."Free Percent" -lt $datastore_warn_level)  {  $ds.status = "[image:20;20;warn.jpg]" }  
        if ([int]$ds."Free Percent" -lt $datastore_alarm_Level )   { $ds.status =  "[image:20;20;alert.jpg]" } 
    
    }

    #Convert resultant array to html table for addition to report. 
    $myhtml_datastores = $mycsv_datastores | Select-Object Status, Name, "Free Percent", "Capacity GB", "Free GB" | Sort-Object "Free Percent"  | ConvertTo-advHtml -Title "Disk Usage Report" -PostContent "<br>Done! $(Get-Date)"
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------
#Get Host Information
My-Logger "working on host stats"
#set limits for alerts
$High_cpu_warn = 60
$High_cpu_alert = 85
$high_mem_warn = 60
$high_mem_alert = 85
$high_vcpuratio_warn = 2
$high_vcpuratio_alert = 2.5

$ReportVmHost="<div id='boxheader'>Host Stats for the last 24hrs (Over $High_cpu_warn% considered warrning and $High_cpu_alert% considered Critical, vCPU Ratio ideally should be below $high_vcpuratio_alert ) </div>"
$datafile = $BasePath  + $Date + "\" + "RVTools_tabvHost.csv"

My-Logger "Testing for inventory file..."
if ( Test-Path ($datafile) )
{          
    My-Logger "Exists, pulling initial data..."            
   #Pull data from RVTools inventory csv file
   $mycsv_hosts = import-csv $datafile | select host,cluster,"# VMs",@{name="# vCPUs";Expression={[int]$_."# vCPUs"}},@{name="vCPU Ratio";Expression={ "{0:N2}" -f ( ([single]$_."# vCPUs" / ([int]$_."# Cores" * 2)) )}} | sort-object cluster
   
   #Add some extra fields for utilisation averages/maximums
   $mycsv_hosts | Add-Member -Type NoteProperty -name ConnectionState -Value  "default"
   $mycsv_hosts | Add-Member -Type NoteProperty -name MemMax -Value  "default"
   $mycsv_hosts | Add-Member -Type NoteProperty -name MemAvg -Value  "default"
   $mycsv_hosts | Add-Member -Type NoteProperty -name CPUMax -Value  "default"
   $mycsv_hosts | Add-Member -Type NoteProperty -name CPUAvg -Value  "default"

   #Create my array to collate all the stats and host info
   
    foreach($vmHost in $mycsv_hosts)
    {
        #Pull stats on each host listed in the csv file
        My-Logger "Getting host connection state"
        $hoststat = get-vmhost  $VmHost.host | Select ConnectionState
                
        My-Logger "Add alert/warn images if in maint mode or disconnected"
        $vmhost.ConnectionState = $hoststat.ConnectionState
        if ($hoststat.ConnectionState -eq 'NotResponding') {$vmhost.connectionstate = "Not Responding [image:20;20;alert.jpg]"}
        if ($hoststat.ConnectionState -eq 'Maintenance') {$vmhost.connectionstate = "Maint Mode [image:20;20;warn.jpg]"}

        My-Logger "Getting host stats for last 24hours for $VmHost.host"
        $statcpu = Get-Stat -Entity $vmHost.host  -start (get-date).AddDays(-1) -Finish (Get-Date)-MaxSamples 10000 -stat cpu.usage.average
        $statmem = Get-Stat -Entity $vmHost.host  -start (get-date).AddDays(-1) -Finish (Get-Date)-MaxSamples 10000 -stat mem.usage.average

        #work out the Max,Min and Average of all the stats
        My-Logger "work out the Max,Min and Average of all the stats"
        $cpu = $statcpu | Measure-Object -Property value -Average -Maximum -Minimum
        $mem = $statmem | Measure-Object -Property value -Average -Maximum -Minimum
        
        my-logger "Add alert/warn images if over limits for CPU for "+ $VmHost.host
        $vmhost.CPUMax = $cpu.Maximum
        $vmHost.CPUAvg = $cpu.Average
        if ($cpu.Maximum -gt $High_cpu_warn) {$vmhost.CPUMax =  [string]("{0:N2}" -f $cpu.Maximum)  + " [image:20;20;warn.jpg]" }
        if ($cpu.Maximum -gt $High_cpu_alert) {$vmhost.CPUMax = [string]("{0:N2}" -f $cpu.Maximum) + " [image:20;20;alert.jpg]"}    
        if ($cpu.Average -gt $High_cpu_warn) {$vmhost.CPUAvg = [string]("{0:N2}" -f $cpu.Average) + " [image:20;20;warn.jpg]"}
        if ($cpu.Average -gt $High_cpu_alert) {$vmhost.CPUAvg = [string]("{0:N2}" -f $cpu.Average) + " [image:20;20;alert.jpg]"}
        
        my-logger "Add alert/warn images if over limits for Memory for " + $VmHost.host
        $vmhost.MemMax = $mem.Maximum
        $vmhost.MemAvg = $mem.Average
        if ($mem.Maximum -gt $High_mem_warn) {$vmhost.memMax =  [string]("{0:N2}" -f $mem.Maximum) + " [image:20;20;warn.jpg]"}
        if ($mem.Maximum -gt $High_mem_alert) {$vmhost.memMax = [string]("{0:N2}" -f $mem.Maximum) + " [image:20;20;alert.jpg]"}    
        if ($mem.Average -gt $High_mem_warn) {$vmhost.memAvg = [string]("{0:N2}" -f $mem.Average) + " [image:20;20;warn.jpg]"}
        if ($mem.Average -gt $High_mem_alert) {$vmhost.memAvg = [string]("{0:N2}" -f $mem.Average) + " [image:20;20;alert.jpg]"}

        my-logger "Add alert/warn images if over vcpu ratio for " + $VmHost.host
        if ($vmhost."vCPU Ratio" -gt $high_vcpuratio_alert)
            {
                $vmhost."vCPU Ratio" = [string]$vmhost."vCPU Ratio" + " [image:20;20;alert.jpg]" 
            }
        else
            {
                if ($vmhost."vCPU Ratio" -gt $high_vcpuratio_warn) 
                    {
                        $vmhost."vCPU Ratio" = [string]$vmhost."vCPU Ratio" + " [image:20;20;warn.jpg]" 
                    }
            }
        
    }
      
}

      my-logger "Report to adv-hmtl to get pretty pictures"
      $myhtml_hosts = $mycsv_hosts | Select Host, cluster,ConnectionState, @{Name = 'Max_Mem_%'; Expression = {"{0:N2}" -f $_.MemMax}} , @{Name = 'Ave_Mem_%'; Expression = {"{0:N2}" -f $_.MemAvg}}, @{Name = 'Max_CPU_%'; Expression = {"{0:N2}" -f $_.CPUMax}}, @{Name = 'Ave_CPU_%'; Expression = {"{0:N2}" -f $_.CPUAvg}},"# VMs","# vCPUs","vCPU Ratio" | sort-object cluster |  ConvertTo-advHtml -Title "Host Summary Report" -PostContent "<br>Done! $(Get-Date)" 

#----------------------------------------------------------------------------------------------------------------------
#Get Host Based Alarms
My-Logger "working on host based alarms"
$Reporthealth="<div id='boxheader'>Host Health </div>"
$datafile = $BasePath  + $Date + "\" + "RVTools_tabvHealth.csv"

if ( Test-Path ($datafile) )
{          
    $myhtml_health =  Import-Csv $datafile | select name,message | where {$_.name -like "*esx*" -and $_.message -notlike "*virtual CPUs active per core on this host*" } | sort-object name | ConvertTo-advHtml -Title "Host Summary Report" -PostContent "<br>Done! $(Get-Date)" 
}
#----------------------------------------------------------------------------------------------------------------------
#Get VMTools Health
My-Logger "working on VMtools"
$Reporttools="<div id='boxheader'>VMTools Check </div>"
$datafile = $BasePath  + $Date + "\" + "RVTools_tabvTools.csv"

if ( Test-Path ($datafile) )
{          

    $mycsv_tools =  import-csv $datafile | select vm,powerstate,tools | where {$_.powerstate -eq "poweredOn" -and $_.tools -like "*Not*"} | sort-object vm 

    foreach ($tool in $mycsv_tools )
    {
        if ($tool.tools -eq "toolsNotInstalled") {$tool.tools = "toolsNotInstalled" + " [image:20;20;alert.jpg]"}
        if ($tool.tools -eq "toolsNotRunning") {$tool.tools = "toolsNotRunning" + " [image:20;20;warn.jpg]"}
    }


    $myhtml_tools = $mycsv_tools | ConvertTo-advHtml -Title "VMTools Health Check" -PostContent "<br>Done! $(Get-Date)"  
}
#----------------------------------------------------------------------------------------------------------------------
#Check Site for Tintri and Tintri based Snapshots
My-Logger "getting tintri snapshots"
if($vCenter -eq "vcsa10-c.games-int.net" )

    {
        #Load the Tintri Powershell module
        $report_Tintrisnaps ="<div id='boxheader'>Open Tintri Snapshots (Any older than 7 days should be deleted)</div>"
    
        Import-Module “C:\Program Files\TintriPSToolKit\TintriPSToolKit.psd1”

        Connect-TintriServer tintri01-c.games-int.net -UserName ReadOnly -Password P@ssw0rd
        Connect-TintriServer tintri02-c.games-int.net -UserName ReadOnly -Password P@ssw0rd
        $tintrisnaplist = get-tintrivmsnapshot | select VMname, createtime | ConvertTo-Html -Fragment

        disconnect-tintriserver tintri01-c.games-int.net
        disconnect-tintriserver tintri02-d.games-int.net
    }
    
    if($vCenter -eq "lndv-vcsa02c.games-int.net" )
    
        {
            #Load the Tintri Powershell module
            $report_Tintrisnaps ="<div id='boxheader'>Open Tintri Snapshots (Any older than 7 days should be deleted)</div>"
        
            Import-Module “C:\Program Files\TintriPSToolKit\TintriPSToolKit.psd1”
    
            Connect-TintriServer tintri01-d.games-int.net -UserName ReadOnly -Password P@ssw0rd
            $tintrisnaplist = get-tintrivmsnapshot | select VMname, createtime | ConvertTo-Html -Fragment
            
            disconnect-tintriserver tintri01-d.games-int.net
        }
       
#----------------------------------------------------------------------------------------------------------------------
#Diconnect vCenter
my-logger "disconecting vcenter"
Disconnect-VIServer * -confirm:$false
#----------------------------------------------------------------------------------------------------------------------
#Finalise Email Body
my-logger "finalising mail body"
$body = "$br  $BoxContentOpener  $PageBoxCloser $intro $br"
$body = $body + "$br $BoxContentOpener $report_graphs  $PageBoxCloser "
$body = $body + "$br $report_summary $BoxContentOpener $mycsv_cluster $PageBoxCloser "
$body = $body + "$br $ReportVmHost $BoxContentOpener $myhtml_hosts $PageBoxCloser "
$body = $body + "$br $report_clusterratio $BoxContentOpener $mycsvclusterratio $PageBoxCloser "
$body = $body + "$br $Reporthealth $BoxContentOpener $myhtml_health $PageBoxCloser "
$body = $body + "$br $Reporttools $BoxContentOpener $myhtml_tools $PageBoxCloser "
$body = $body + "$br $report_powerstats $BoxContentOpener $mycsv_powerstats $PageBoxCloser "
$body = $body + "$br $report_Snapshots $BoxContentOpener $mycsv_snapshots $PageBoxCloser "
$body = $body + "$br $report_Tintrisnaps  $BoxContentOpener $tintrisnaplist $PageBoxCloser"
$body = $body + "$br $report_datastores $BoxContentOpener $myhtml_datastores $PageBoxCloser "

#----------------------------------------------------------------------------------------------------------------------
#Build and send  Email 
my-logger "building and sending email"
$msg = new-object Net.Mail.MailMessage
$smtp = new-object Net.Mail.SmtpClient($smtpServer)

$msg.From = "daily_summary@sg-tech.co.uk"#
$msg.ReplyTo = "daily_summary@sg-tech.co.uk"
$msg.To.Add("mike.howard@sg-tech.co.uk")
$msg.subject = "Daily Summary $location for $Date"

$msg.IsBodyHtml = $True
$msg.Body = " $Css  $body "

#Build the attachment images
$attachment = New-Object System.Net.Mail.Attachment –ArgumentList "F:\Scripts\_Production\daily-summary\Images\SMARTGAMESTECH_LOGO_HORIZONTAL_MINI.jpg"
$attachment.ContentDisposition.Inline = $True
$attachment.ContentDisposition.DispositionType = "Inline"
$attachment.ContentType.MediaType = "image/jpg"
$attachment.ContentId = 'SMARTGAMESTECH_LOGO_HORIZONTAL_MINI.jpg'
$msg.Attachments.Add($attachment)

$attachment = New-Object System.Net.Mail.Attachment –ArgumentList "F:\Scripts\_Production\daily-summary\Images\alert.jpg"
$attachment.ContentDisposition.Inline = $True
$attachment.ContentDisposition.DispositionType = "Inline"
$attachment.ContentType.MediaType = "image/jpg"
$attachment.ContentId = 'alert.jpg'
$msg.Attachments.Add($attachment)

$attachment = New-Object System.Net.Mail.Attachment –ArgumentList "F:\Scripts\_Production\daily-summary\Images\warn.jpg"
$attachment.ContentDisposition.Inline = $True
$attachment.ContentDisposition.DispositionType = "Inline"
$attachment.ContentType.MediaType = "image/jpg"
$attachment.ContentId = 'warn.jpg'
$msg.Attachments.Add($attachment)

$attachment = New-Object System.Net.Mail.Attachment –ArgumentList "F:\Scripts\_Production\daily-summary\Images\tick.jpg"
$attachment.ContentDisposition.Inline = $True
$attachment.ContentDisposition.DispositionType = "Inline"
$attachment.ContentType.MediaType = "image/jpg"
$attachment.ContentId = 'tick.jpg'
$msg.Attachments.Add($attachment)

$attachment = New-Object System.Net.Mail.Attachment –ArgumentList "F:\Scripts\_Production\daily-summary\images\Powerstats-$location.png"
$attachment.ContentDisposition.Inline = $True
$attachment.ContentDisposition.DispositionType = "Inline"
$attachment.ContentType.MediaType = "image/jpg"
$attachment.ContentId = 'Poweredstats-$vcenter'
$msg.Attachments.Add($attachment)

$attachment = New-Object System.Net.Mail.Attachment –ArgumentList "F:\Scripts\_Production\daily-summary\images\vcpustats-$location.png"
$attachment.ContentDisposition.Inline = $True
$attachment.ContentDisposition.DispositionType = "Inline"
$attachment.ContentType.MediaType = "image/jpg"
$attachment.ContentId = 'vcpustats-$vcenter'
$msg.Attachments.Add($attachment)

$attachment = New-Object System.Net.Mail.Attachment –ArgumentList "F:\Scripts\_Production\daily-summary\images\memorystats-$location.png"
$attachment.ContentDisposition.Inline = $True
$attachment.ContentDisposition.DispositionType = "Inline"
$attachment.ContentType.MediaType = "image/jpg"
$attachment.ContentId = 'memorystats-$vcenter'
$msg.Attachments.Add($attachment)


$smtp.Send($msg)
$attachment.Dispose();
$msg.Dispose();
My-Logger "Done !"


