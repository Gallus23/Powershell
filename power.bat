::Execute a Powershell script from a CMD
rem Powershell.exe -NonInteractive -NoLogo -NoProfile -Command "D:\Software\Scripts\Global_Power_Stats.ps1" 2>&1> "D:\software\scripts\log\Log.txt"
powershell -ExecutionPolicy RemoteSigned -NoProfile -NonInteractive -command "D:\Software\Scripts\Global_Power_Stats.ps1" 2>&1> "D:\Software\Scripts\lastrun.txt"
