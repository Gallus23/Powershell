
d:
cd \software\scripts


powershell ".\vCD_DS9_SyncTest.ps1  -vcddns lo1-mystack.pearson.com -org test1 -orgnet FE   -catalog 'lo1-public-catalog' -template 'RHEL6-64bit' -delay 120 -user DS9_Sync_Test  -pwd DS9_Sync_Test" > d:\software\scripts\log\global_ds9_sync_vapp_deploy.txt
powershell ".\vCD_DS9_SyncTest.ps1  -vcddns lo3-mystack.pearson.com -org test1 -orgnet FE   -catalog 'lo3-public-catalog' -template 'RHEL6-64bit' -delay 120 -user DS9_Sync_Test  -pwd DS9_Sync_Test" >> d:\software\scripts\log\global_ds9_sync_vapp_deploy.txt
powershell ".\vCD_DS9_SyncTest.ps1  -vcddns nj2-mystack.pearson.com -org test1 -orgnet FE   -catalog 'nj2-public-catalog' -template 'RHEL6-64bit' -delay 120 -user DS9_Sync_Test  -pwd DS9_Sync_Test" >> d:\software\scripts\log\global_ds9_sync_vapp_deploy.txt
powershell ".\vCD_DS9_SyncTest.ps1  -vcddns icd-mystack.pearson.com -org myStack-Test -orgnet FE   -catalog 'icd-public-catalog' -template 'RHEL6-64bit' -delay 120 -user DS9_Sync_Test  -pwd DS9_Sync_Test" >> d:\software\scripts\log\global_ds9_sync_vapp_deploy.txt
powershell ".\vCD_DS9_SyncTest.ps1  -vcddns au1-mystack.pearson.com -org test1 -orgnet FE   -catalog 'au1-public-catalog' -template 'RHEL6-64bit' -delay 120 -user DS9_Sync_Test  -pwd DS9_Sync_Test" >> d:\software\scripts\log\global_ds9_sync_vapp_deploy.txt
powershell ".\vCD_DS9_SyncTest.ps1  -vcddns sh1-mystack.pearson.com -org test1 -orgnet FE   -catalog 'sh1-public-catalog' -template 'RHEL6-64bit' -delay 120 -user DS9_Sync_Test  -pwd DS9_Sync_Test" >> d:\software\scripts\log\global_ds9_sync_vapp_deploy.txt
powershell ".\vCD_DS9_SyncTest.ps1  -vcddns bj1-mystack.pearson.com -org test1 -orgnet FE   -catalog 'bj1-public-catalog' -template 'RHEL6-64bit' -delay 120 -user DS9_Sync_Test  -pwd DS9_Sync_Test" >> d:\software\scripts\log\global_ds9_sync_vapp_deploy.txt
powershell ".\vCD_DS9_SyncTest.ps1  -vcddns sg8-mystack.pearson.com -org test1 -orgnet FE   -catalog 'sg8-public-catalog' -template 'RHEL6-64bit' -delay 120 -user DS9_Sync_Test  -pwd DS9_Sync_Test" >> d:\software\scripts\log\global_ds9_sync_vapp_deploy.txt
powershell ".\vCD_DS9_SyncTest.ps1  -vcddns bz1-mystack.pearson.com -org Test1 -orgnet FE   -catalog 'bz1-public-catalog' -template 'vcd-RHEL6-64-2014-OCT-30' -delay 120 -user DS9_Sync_Test  -pwd DS9_Sync_Test" >> d:\software\scripts\log\global_ds9_sync_vapp_deploy.txt

echo completed >> d:\software\scripts\log\global_ds9_sync_vapp_deploy.txt


 