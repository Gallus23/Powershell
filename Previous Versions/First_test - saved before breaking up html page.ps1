#Variable declaration
param([string]$Location)

#Test connection local datacebter folder
Write-Host "Checking for local Datacenter Folder" -foregroundcolor "magenta" 
if(!(Test-path D:\myStackOps\Datacenters\$location))
{
write-host "No Datacenter Folder found, please create if required. Exiting " -foregroundcolor "red" 
exit
}

$vCenterIPorFQDN=$location + "wrvcdvcs002.dcsprod.dcsroot.local"

#Test connection to destination vCenter
Write-Host "Testing Connection to vCenter" -foregroundcolor "magenta" 
if(!(Test-Connection -Cn $vCenterIPorFQDN -BufferSize 16 -Count 1 -ea 0 -quiet))
{
write-host "Connection to $vCenterIPorFQDN failed cannot ping" -foregroundcolor "red" 
exit
}

$vCenterUsername = "mystackops@dcsutil.dcsroot.local"
$vCenterPassword = "#0rs3Sh03"
$OutputPath = "D:\myStackOps\datacenters\" + $location + "\" 	#Location where you want to place generated report
$date = Get-Date -format s
$outputfile = $OutputPath + $date.substring(0,10) + ".html"

Write-Host "Connecting to vCenter" -foregroundcolor "magenta" 
Connect-VIServer -Server $vCenterIPorFQDN -User $vCenterUsername -Password $vCenterPassword

#--------------------------------------------------------------------------------------------------------------------------------------
#This is the CSS used to add the style to the report

$Css="<style>
body {
    font-family: Verdana, sans-serif;
    font-size: 14px;
	color: #666666;
	background: #FEFEFE;
}
#title{
	color:#FF9900;
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
	border:1px solid #FF9900;
	padding:3px 7px 2px 7px;
}
table th {
	text-align:left;
	padding-top:5px;
	padding-bottom:4px;
	background-color:#FF9900;
color:#fff;
}
table tr.alt td {
	color:#000;
	background-color:#EAF2D3;
}
</style>"

#--------------------------------------------------------------------------------------------------------------------------------------
#This is the javascript used to dectect warnings and erros and colour the cells appropriately.
$htmlheader = @"
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"></script>
<script type="text/javascript">
`$(document).ready(function(){
  `$( "td:contains('yellow')" ).css('background-color', '#FDF099'); //If yellow alarm triggered set cell background color to yellow
	`$( "td:contains('yellow')" ).text('Warning'); //Replace text 'yellow' with 'Warning'
	`$( "td:contains('red')" ).css('background-color', '#FCC' ); //If red alarm triggered set cell background color to red
	`$( "td:contains('red')" ).text('Alert'); //Replace text 'red' with 'Alert'
	`$( "td:contains('Normal')" ).css('background-color', '#C8DC80' ); //If red alarm triggered set cell background color to red
});
</script>
		
"@
#--------------------------------------------------------------------------------------------------------------------------------------
#These are the sections of css for the report

$PageBoxOpener="<div id='box1'>"
$ReportVmHost="<div id='boxheader'>Host Information $Location</div>"
$BoxContentOpener="<div id='boxcontent'>"
$PageBoxCloser="</div>"
$br="<br>" #This should have been defined in CSS but if you need new line you could also use it this way

#--------------------------------------------------------------------------------------------------------------------------------------
#These are the text headers for each section

$ReportGetDatastore="<div id='boxheader'>DataStore Stats </div>"
$ReportGetalarms="<div id='boxheader'>Host based alarms </div>"
$ReportGetevents="<div id='boxheader'>Error Events in the last day </div>"

#--------------------------------------------------------------------------------------------------------------------------------------
#This where the checks begin

#Get VMHost infos
$VmHost=Get-VMHost | Select-Object @{Name = 'Host'; Expression = {$_.Name}},State,ConnectionState,NumCpu,@{Name = 'CpuTotalGhz'; Expression = {"{0:N2}" -f ($_.CpuTotalMhz/1000)}},@{Name = 'CpuUsageGhz'; Expression = {"{0:N2}" -f ($_.CpuUsageMhz/1000)}},@{Name = 'MemoryTotalGB'; Expression = {"{0:N2}" -f $_.MemoryTotalGB}}, @{Name = 'MemoryUsageGB'; Expression = {"{0:N2}" -f $_.MemoryUsageGB}} | ConvertTo-HTML -Fragment

#--------------------------------------------------------------------------------------------------------------------------------------
#Get Datastore Details
$datastores=get-datastore 
ForEach ($ds in $datastores)
{  
$PercentFree = ($ds.FreeSpaceMB /  $ds.CapacityMB) * 100
  $PercentFree = "{0:N2}" -f $PercentFree  
  $ds | Add-Member -type NoteProperty -name PercentFree -value $PercentFree  
  if ($PercentFree -lt 30) 
  {
	$ds | Add-Member -type NoteProperty -name Status -value 'yellow'  
  }
  else
  {
	if ($PercentFree -lt 20)
	{
	$ds | Add-Member -type NoteProperty -name Status -value 'red'  
	}
	else
	{
	$ds | Add-Member -type NoteProperty -name Status -value 'Normal'
	}
  }
} 

$getdatastore = $datastores | select-object Name, status, CapacityGB, @{Name = 'Free GB'; Expression = {"{0:N2}" -f $_.FreeSpaceGB}}, PercentFree | Sort-Object Free -descending  | ConvertTo-HTML -Fragment

#--------------------------------------------------------------------------------------------------------------------------------------
#Get Host level Alarms
$hosts = Get-VMHost | Get-View #Retrieve all hosts from vCenter
 
foreach ($esxihost in $hosts){ 												#For each Host
    foreach($triggered in $esxihost.TriggeredAlarmState){ 					#For each triggered alarm of each host
            $arrayline={} | Select HostName, AlarmType, AlarmInformations 	#Initialize line
            $alarmDefinition = Get-View -Id $triggered.Alarm 				#Get info on Alarm
            $arrayline.HostName = $esxihost.Name 							#Get host which has this alarm triggered
			$arrayline.AlarmType = $triggered.OverallStatus 				#Get if this is a Warning or an Alert
            $arrayline.AlarmInformations = $alarmDefinition.Info.Name 		#Get infos about alarm
            $HostList += $arrayline 										#Add line to array
			$HostList = @($HostList) 										#Post-Declare this is an array
    }
}

$getalarms = $HostList | select HostName, AlarmType, AlarmInformations | ConvertTo-HTML -Fragment

#Listevents
$Getevents = Get-VIEvent  -types error -Start (Get-Date).AddDays(-1) | sort-object createdtime -descending | select CreatedTime, Username, FullFormattedMessage | ConvertTo-HTML -Fragment

#--------------------------------------------------------------------------------------------------------------------------------------
#Disconnect the vCenter
#disconnect-viserver -server * -Confirm:$false -force

#--------------------------------------------------------------------------------------------------------------------------------------
#Create HTML report
#- Use $htmlheader on div section of convert-to html to kick of script

ConvertTo-Html -Title "Test Title" -Head "<div id='title'>myStack Daily Reporting $location </div>$br<div id='subtitle'>Report generated: $(Get-Date)</div>$htmlheader" -Body " $Css $PageBoxOpener $ReportVmHost $BoxContentOpener $VmHost $PageBoxCloser $br $ReportGetCluster $BoxContentOpener $GetCluster $PageBoxCloser $br $ReportGetalarms $BoxContentOpener $getalarms $PageBoxCloser $br $ReportGetDatastore $BoxContentOpener $getdatastore $PageBoxCloser $br $ReportGetVmCluster $BoxContentOpener $GetVmCluster $PageBoxCloser $br $ReportGetevents $BoxContentOpener $Getevents $PageBoxCloser"  | Out-File $outputfile


#Notes
##$br $ReportGetCluster $BoxContentOpener $GetCluster $PageBoxCloser

