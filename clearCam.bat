@echo off

:: Filter
set "FILE_FILTER='(.thm)|(.wav)|(.lrv)|(.jpg)|(.mp4)$'"

:: Front Info
set FRONT_NAME='Fusion Front'
set FRONT_DIR='GoPro MTP Client Disk SD2\DCIM\100GFRNT'

:: Back Info
set BACK_NAME='Fusion Back'
set BACK_DIR='GoPro MTP Client Disk SD1\DCIM\100GBACK'

powershell.exe -Command "%~dp0utils\DeviceFiles.ps1" -deleteAll -deviceName "%FRONT_NAME%" -sourceFolder "%FRONT_DIR%" -filter "%FILE_FILTER%"

powershell.exe -Command "%~dp0utils\DeviceFiles.ps1" -deleteAll -deviceName "%BACK_NAME%" -sourceFolder "%BACK_DIR%" -filter "%FILE_FILTER%"

echo.
echo Done!
echo.
