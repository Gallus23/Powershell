rem This script run pre patch processes for the first cycle of servers

d:
cd \software\scripts

powershell ".\Pre-patch-first-cycle.ps1  -location %1" > d:\software\scripts\log\%1-Pre_Patch_1st_cycle.txt