rem @echo off
set _curPath=%~dp0
pushd "%_curPath%"


HPFirmwareInstaller.exe

mkdir "c:\Program Files\HP\HP Firmware Installer\HP Thunderbolt Dock G4"
xcopy /y HPFIVersion.dll "c:\Program Files\HP\HP Firmware Installer\HP Thunderbolt Dock G4"
popd
exit /b %ERRORLEVEL%