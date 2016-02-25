rem This script run pre patch processes for the third cycle of servers

d:
cd \software\scripts

powershell ".\Pre-patch-Third-cycle.ps1  -location %1" > d:\software\scripts\log\%1-Pre_Patch_3rd_cycle.txt