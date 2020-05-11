@echo off

:: Filter
set "FILE_FILTER='(.thm)|(.wav)|(.lrv)|(.jpg)|(.mp4)$'"

:: Front Info
set FRONT_NAME='Fusion Front'
set FRONT_DIR='GoPro MTP Client Disk SD2\DCIM\100GFRNT'

:: Back Info
set BACK_NAME='Fusion Back'
set BACK_DIR='GoPro MTP Client Disk SD1\DCIM\100GBACK'

set DST_FOLDER=%~f1
echo Destination Folder is %DST_FOLDER%

set DST_FOLDER_FRONT=%DST_FOLDER%\Front
echo Destination Folder Front is %DST_FOLDER_FRONT%

set DST_FOLDER_BACK=%DST_FOLDER%\Back
echo Destination Folder Back is %DST_FOLDER_BACK%

powershell.exe -Command "%~dp0utils\DeviceFiles.ps1" -moveAll -deviceName "%FRONT_NAME%" -sourceFolder "%FRONT_DIR%" -targetFolder "%DST_FOLDER_FRONT%" -filter "%FILE_FILTER%"

powershell.exe -Command "%~dp0utils\DeviceFiles.ps1" -moveAll -deviceName "%BACK_NAME%" -sourceFolder "%BACK_DIR%" -targetFolder "%DST_FOLDER_BACK%" -filter "%FILE_FILTER%"

echo.
echo Done!
echo.
