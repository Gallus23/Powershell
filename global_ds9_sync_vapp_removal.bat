
d:
cd \software\scripts

powershell ".\Remove_DS9_vCD_Sync.ps1 -vcddns lo1-mystack.pearson.com -user DS9_Sync_Test  -pwd DS9_Sync_Test -org test1" > d:\software\scripts\log\global_ds9_sync_vapp_removal.txt
powershell ".\Remove_DS9_vCD_Sync.ps1 -vcddns lo3-mystack.pearson.com -user DS9_Sync_Test  -pwd DS9_Sync_Test -org test1" >> d:\software\scripts\log\global_ds9_sync_vapp_removal.txt
powershell ".\Remove_DS9_vCD_Sync.ps1 -vcddns nj2-mystack.pearson.com -user DS9_Sync_Test  -pwd DS9_Sync_Test -org test1" >> d:\software\scripts\log\global_ds9_sync_vapp_removal.txt
powershell ".\Remove_DS9_vCD_Sync.ps1 -vcddns icd-mystack.pearson.com -user DS9_Sync_Test  -pwd DS9_Sync_Test -org myStack-Test" >> d:\software\scripts\log\global_ds9_sync_vapp_removal.txt
powershell ".\Remove_DS9_vCD_Sync.ps1 -vcddns au1-mystack.pearson.com -user DS9_Sync_Test  -pwd DS9_Sync_Test -org test1" >> d:\software\scripts\log\global_ds9_sync_vapp_removal.txt
powershell ".\Remove_DS9_vCD_Sync.ps1 -vcddns sh1-mystack.pearson.com -user DS9_Sync_Test  -pwd DS9_Sync_Test -org test1" >> d:\software\scripts\log\global_ds9_sync_vapp_removal.txt
powershell ".\Remove_DS9_vCD_Sync.ps1 -vcddns bj1-mystack.pearson.com -user DS9_Sync_Test  -pwd DS9_Sync_Test -org test1" >> d:\software\scripts\log\global_ds9_sync_vapp_removal.txt
powershell ".\Remove_DS9_vCD_Sync.ps1 -vcddns sg8-mystack.pearson.com -user DS9_Sync_Test  -pwd DS9_Sync_Test -org test1" >> d:\software\scripts\log\global_ds9_sync_vapp_removal.txt
powershell ".\Remove_DS9_vCD_Sync.ps1 -vcddns bz1-mystack.pearson.com -user DS9_Sync_Test  -pwd DS9_Sync_Test -org Test1" >> d:\software\scripts\log\global_ds9_sync_vapp_removal.txt
 
 echo completed >> d:\software\scripts\log\global_ds9_sync_vapp_removal