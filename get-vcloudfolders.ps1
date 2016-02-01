#Variable declaration
param(
	[string]$Location
	)

Add-PSSnapin vmware.vimautomation.cloud

$vCloudFQDN=$location + "-mystack.pearson.com"

#This is a comment
#this is another comment

#Test connection to destination vCenter
Write-Host "Testing Connection to vCloud" -foregroundcolor "magenta"
if(!(Test-Connection -Cn $vCloudFQDN -BufferSize 16 -Count 1 -ea 0 -quiet))
{
write-host "Connection to $vCloudFQDN failed cannot ping" -foregroundcolor "red"
exit
}

$vCloudUsername = "ahowami"
$vCloudPassword = "Screen143"
$outputfile = "D:\Software\Scripts\vcloudfolders.csv"

$vCloudFQDN=$location + "-mystack.pearson.com"


Connect-CIServer -Server $vCloudFQDN -User $vCloudUsername -Password $vCloudPassword

 Get-CIVApp | select org, name | sort Org,name | Export-Csv  $outputfile

 #--------------------------------------------------------------------------------------------------------------------------------------
#Disconnect the vCloud
write-host "Disconnecting vCloud......."
disconnect-ciserver -server * -Confirm:$false -force
