


Get-VMHost | Sort Name | Foreach {
    $ESXCLI = Get-EsxCli -VMHost $_ -ErrorAction SilentlyContinue
    $ESXCLI.software.vib.list() | Where { $_.Name -like "*vCloud*"} | Select @{N="VMHost";E={$ESXCLI.VMHost}}, Name, Version
}