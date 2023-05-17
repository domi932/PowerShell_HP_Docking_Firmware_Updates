@echo off
set _curPath=%~dp0
pushd "%_curPath%"

if %PROCESSOR_ARCHITECTURE%==x86 goto set_bitness_32
if %PROCESSOR_ARCHITECTURE%==AMD64 goto set_bitness_64
if %PROCESSOR_ARCHITECTURE%==IA64 goto set_bitness_64
if %PROCESSOR_ARCHITECTURE%==EM64T goto set_bitness_64
if %PROCESSOR_ARCHITECTURE%==ARM goto set_bitness_32
if %PROCESSOR_ARCHITECTURE%==ARM64 goto set_bitness_32
goto Default

:set_bitness_32
set _msiPath="Manageability\HPFirmwareInstaller.msi"
goto Finish

:set_bitness_64
:Default
set _msiPath="Manageability\HPFirmwareInstaller64.msi"
goto Finish

:Finish
rem echo ...........................................................
rem echo The _msiPath is %_msiPath%
rem echo ...........................................................
rem pause
@echo on

msiexec /i %_msiPath% /qn %*
set _retCode=%ERRORLEVEL%

HPFirmwareInstaller.exe -s
Manageability\HPDockWMIProvider.exe /S /v/qn

popd
exit /b %_retCode%