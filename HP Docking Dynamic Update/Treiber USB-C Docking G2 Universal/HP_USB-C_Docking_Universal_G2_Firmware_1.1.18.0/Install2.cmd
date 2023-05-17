rem @echo off
set _curPath=%~dp0
pushd "%_curPath%"


HPFirmwareInstaller.exe

mkdir "c:\Program Files\HP\HP Firmware Installer\HP USB-C&A Universal Dock G2"
xcopy /y HPFIVersion.dll "c:\Program Files\HP\HP Firmware Installer\HP USB-C&A Universal Dock G2"
popd
exit /b %ERRORLEVEL%