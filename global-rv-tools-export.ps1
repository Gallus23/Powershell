

<# 
.SYNOPSIS 
   Performs full export from RVTools
.DESCRIPTION
   Performs full export from RVTools. Archives old versions.
.PARAMETER Servers
   Specify which vCenter server(s) to connect to
.PARAMETER BasePath
   Specify the path to export to. Server name and date appended.
.PARAMETER OldFileDays
   How many days to retain copies
#>
param
(
   $Servers = @("lndv-vcsa02c.games-int.net","lnov-vcsa01.games-int.net","hhov-vcsa02.mare.esailors.net","vm-vcsa-04-hh1.t24de.tipp24.net","mdov-vcsa03.games-int.net","vcsa10-c.games-int.net"),
   $BasePath = "C:\Share\_Inventory_Information\Exports",
   $OldFileDays = 3
)

$Date = (Get-Date -f "yyyyMMdd")

foreach ($Server in $Servers)
{
   # Create Directory
   New-Item -Path "$BasePath\$Server\$date" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

   # Run Export
   ."C:\Program Files (x86)\RobWare\RVTools\rvtools.exe" -u "games-int\svc-rvtools" -p Passw0rd -s "$Server" -c ExportAll2csv -d "$BasePath\$Server\$Date"

   # Cleanup old files
   $Items = Get-ChildItem "$BasePath\$server"
   foreach ($item in $items)
   {
      $itemDate = ("{0}/{1}/{2}" -f $item.name.Substring(6,2),$item.name.Substring(4,2),$item.name.Substring(0,4))
      
      if ((((Get-date).AddDays(-$OldFileDays))-(Get-Date($itemDate))).Days -gt 0)
      {
         $item | Remove-Item -Recurse
      }
   }
}