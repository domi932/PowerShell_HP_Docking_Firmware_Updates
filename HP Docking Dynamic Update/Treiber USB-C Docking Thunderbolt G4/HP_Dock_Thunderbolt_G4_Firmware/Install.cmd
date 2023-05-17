@echo off
set _curPath=%~dp0
pushd "%_curPath%"

rem no need to check if PROCESSOR_ARCHITECTURE is IA64, EM64T, ARM, or ARM64 because code will not work in these environments 
if %PROCESSOR_ARCHITECTURE%==x86 goto set_bitness_32
if %PROCESSOR_ARCHITECTURE%==AMD64 goto set_bitness_64
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

rem /i specifies normal installation 
rem /qn specifies there is no UI during the installation process 
msiexec /i %_msiPath% /qn %*
set _retCode=%ERRORLEVEL%

rem runs HPFirmwareInstaller.exe in silent mode
rem please note that HPFirmwareInstaller.exe -ni is not a silent install 
HPFirmwareInstaller.exe -s

rem runs HPDockWMIProvider.exe 
Manageability\HPDockWMIProvider.exe /S /v/qn

popd
exit /b %_retCode%