c:
cd \progra~1\tivoli\tsm\baclient

set backupfile=TSM_%date:~-4,4%%date:~-7,2%%date:~-10,2%

dsmadmc -id=reports -password=reports ictsm20:q event * * node=*vcd* begind=-2 > D:\myStackOps\Datacenters\ICD\TSM-Backups\%backupfile%.txt
echo . >> D:\myStackOps\Datacenters\ICD\TSM-Backups\%backupfile%.txt
echo **************************************************************************************************** >> D:\myStackOps\Datacenters\ICD\TSM-Backups\%backupfile%.txt
echo Checking for Backups on Spinit server >> D:\myStackOps\Datacenters\ICD\TSM-Backups\%backupfile%.txt
echo . >> D:\myStackOps\Datacenters\ICD\TSM-Backups\%backupfile%.txt
dsmadmc -id=reports -password=reports ictsm20:q event * * node=*spinitfil* begind=-1 >> D:\myStackOps\Datacenters\ICD\TSM-Backups\%backupfile%.txt


dsmadmc -id=reports -password=reports BZ1TSM01:q event * * node=*vcd* begind=-1 > D:\myStackOps\Datacenters\BZ1\TSM-Backups\%backupfile%.txt
echo . >> D:\myStackOps\Datacenters\BZ1\TSM-Backups\%backupfile%.txt
echo **************************************************************************************************** >> D:\myStackOps\Datacenters\ICD\TSM-Backups\%backupfile%.txt
echo Checking for Backups on Spinit server >> D:\myStackOps\Datacenters\BZ1\TSM-Backups\%backupfile%.txt
echo . >> D:\myStackOps\Datacenters\BZ1\TSM-Backups\%backupfile%.txt
dsmadmc -id=reports -password=reports BZ1TSM01:q event * * node=*spinitfil* begind=-1 >> D:\myStackOps\Datacenters\BZ1\TSM-Backups\%backupfile%.txt


dsmadmc -id=reports -password=reports bj1tsm01:q event * * node=*vcd* > D:\myStackOps\Datacenters\BJ1\TSM-Backups\%backupfile%.txt
echo . >> D:\myStackOps\Datacenters\BJ1\TSM-Backups\%backupfile%.txt
echo **************************************************************************************************** >> D:\myStackOps\Datacenters\BJ1\TSM-Backups\%backupfile%.txt
echo Checking for Backups on Spinit server >> D:\myStackOps\Datacenters\BJ1\TSM-Backups\%backupfile%.txt
echo . >> D:\myStackOps\Datacenters\BJ1\TSM-Backups\%backupfile%.txt
dsmadmc -id=reports -password=reports bj1tsm01:q event * * node=*spinitfil* begind=-1>> D:\myStackOps\Datacenters\BJ1\TSM-Backups\%backupfile%.txt



dsmadmc -id=reports -password=reports sh1tsm01:q event * * node=*vcd* > D:\myStackOps\Datacenters\SH1\TSM-Backups\%backupfile%.txt
echo . >> D:\myStackOps\Datacenters\sh1\TSM-Backups\%backupfile%.txt
echo **************************************************************************************************** >> D:\myStackOps\Datacenters\sh1\TSM-Backups\%backupfile%.txt
echo Checking for Backups on Spinit server >> D:\myStackOps\Datacenters\sh1\TSM-Backups\%backupfile%.txt
echo . >> D:\myStackOps\Datacenters\sh1\TSM-Backups\%backupfile%.txt
dsmadmc -id=reports -password=reports sh1tsm01:q event * * node=*spinitfil* >> D:\myStackOps\Datacenters\SH1\TSM-Backups\%backupfile%.txt



dsmadmc -id=reports -password=reports sg8tsm01:q event * * node=*vcd* begind=-1 > D:\myStackOps\Datacenters\SG8\TSM-Backups\%backupfile%.txt
echo . >> D:\myStackOps\Datacenters\sg8\TSM-Backups\%backupfile%.txt
echo **************************************************************************************************** >> D:\myStackOps\Datacenters\sg8\TSM-Backups\%backupfile%.txt
echo Checking for Backups on Spinit server >> D:\myStackOps\Datacenters\sg8\TSM-Backups\%backupfile%.txt
echo . >> D:\myStackOps\Datacenters\sg8\TSM-Backups\%backupfile%.txt
dsmadmc -id=reports -password=reports sg8tsm01:q event * * node=*spinitfil* begind=-1 >> D:\myStackOps\Datacenters\SG8\TSM-Backups\%backupfile%.txt



dsmadmc -id=reports -password=reports au1tsm02:q event * * node=*vcd* > D:\myStackOps\Datacenters\AU1\TSM-Backups\%backupfile%.txt
echo . >> D:\myStackOps\Datacenters\au1\TSM-Backups\%backupfile%.txt
echo **************************************************************************************************** >> D:\myStackOps\Datacenters\AU1\TSM-Backups\%backupfile%.txt
echo Checking for Backups on Spinit server >> D:\myStackOps\Datacenters\au1\TSM-Backups\%backupfile%.txt
echo . >> D:\myStackOps\Datacenters\au1\TSM-Backups\%backupfile%.txt
dsmadmc -id=reports -password=reports au1tsm02:q event * * node=*spinitfil* >> D:\myStackOps\Datacenters\AU1\TSM-Backups\%backupfile%.txt



dsmadmc -optfile=dsmlo1.opt -id=mystackreport -password=password q event * * node=*vcd* begind=-1 > D:\myStackOps\Datacenters\LO1\TSM-Backups\%backupfile%.txt
echo . >> D:\myStackOps\Datacenters\lo1\TSM-Backups\%backupfile%.txt
echo **************************************************************************************************** >> D:\myStackOps\Datacenters\lo1\TSM-Backups\%backupfile%.txt
echo Checking for Backups on Spinit server >> D:\myStackOps\Datacenters\lo1\TSM-Backups\%backupfile%.txt
echo . >> D:\myStackOps\Datacenters\lo1\TSM-Backups\%backupfile%.txt
dsmadmc -optfile=dsmlo1.opt -id=mystackreport -password=password q event * * node=*spinitfil* begind=-1 >> D:\myStackOps\Datacenters\LO1\TSM-Backups\%backupfile%.txt



dsmadmc -optfile=dsmlo3.opt -id=mystackreport -password=password q event * * node=*vcd* begind=-1 > D:\myStackOps\Datacenters\LO3\TSM-Backups\%backupfile%.txt
echo . >> D:\myStackOps\Datacenters\lo3\TSM-Backups\%backupfile%.txt
echo **************************************************************************************************** >> D:\myStackOps\Datacenters\lo3\TSM-Backups\%backupfile%.txt
echo Checking for Backups on Spinit server >> D:\myStackOps\Datacenters\lo3\TSM-Backups\%backupfile%.txt
echo . >> D:\myStackOps\Datacenters\lo3\TSM-Backups\%backupfile%.txt
dsmadmc -optfile=dsmlo3.opt -id=mystackreport -password=password q event * * node=*spinitfil* begind=-1 >> D:\myStackOps\Datacenters\LO3\TSM-Backups\%backupfile%.txt