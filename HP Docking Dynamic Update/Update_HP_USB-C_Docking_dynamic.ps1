#region Get Information about currently connected Dockingstation
function Get-HP_Docking_Info{
    #Install HPDockWMIProvider to enable reading out Information from HP Dockingstations
    if (!(Test-Path  'C:\ProgramData\HP\HP_DockAccessory')) {

    Start-Process -Wait -FilePath "$PSScriptRoot\HPDockWMIProvider.exe" -ArgumentList "/S /v/qn"

    Write-Host("HPDockWMIProvider has been installed.")
    Start-Sleep -Seconds 3

    } 

    $namespace = "ROOT\HP\InstrumentedServices\v1"

    $classname = "HP_DockAccessory"

    $global:DockingProductName = Get-WmiObject -Class $classname -Namespace $namespace | Select-Object -expandproperty ProductName
    $global:DockingVersion = Get-WmiObject -Class $classname -Namespace $namespace | Select-Object -expandproperty firmwarepackageversion

    $Dockin1 = Get-WmiObject -Class $classname -Namespace $namespace 
    }
#endregion

#region update currently connected HP Dockingstation
function Update-HP_Docking{
    Get-HP_Docking_Info
    if ($global:DockingProductName -ne $null) {
        switch ($global:DockingProductName)
        {
            "HP USB-C Dock G5" {
                $CurrentVersionG5 = "1.0.18.0"
                if ([System.Version]$global:DockingVersion -lt [System.Version]$CurrentVersionG5){
                    write-host("Dockingstation: " + $global:DockingProductName)
                    Write-Host("Current Version: " + $global:DockingVersion)
                    Start-Process -Wait -FilePath "$PSScriptRoot\Treiber USB-C Docking G5\HP_USB-C_Docking_G5_Firmware_1.0.18.0\HPFirmwareInstaller.exe" -ArgumentList "-s"
                    HP_Docking_Info
                    write-host("Dockingstation has been updated.")
                    write-host("Dockingstation: " + $global:DockingProductName)
                    Write-Host("New Version: " + $global:DockingVersion)
                    }
                }
            "HP USB-C/A Universal Dock G2" {
                $CurrentVersionG2 = "1.1.18.0"
                if ([System.Version]$global:DockingVersion -lt [System.Version]$CurrentVersionG2){
                    write-host("Dockingstation: " + $global:DockingProductName)
                    Write-Host("Current Version: " + $global:DockingVersion)
                    Start-Process -Wait -FilePath "$PSScriptRoot\Treiber USB-C Docking G2 Universal\HP_USB-C_Docking_Universal_G2_Firmware_1.1.18.0\HPFirmwareInstaller.exe" -ArgumentList "-s"
                    HP_Docking_Info
                    write-host("Dockingstation has been updated.")
                    write-host("Dockingstation: " + $global:DockingProductName)
                    Write-Host("New Version: " + $global:DockingVersion)
                    }

                }
            "HP Thunderbolt Dock G4" {
                $CurrentVersionThunderboltG4 = "1.4.16.0"
                if ([System.Version]$global:DockingVersion -lt [System.Version]$CurrentVersionThunderboltG4){
                    write-host("Dockingstation: " + $global:DockingProductName)
                    Write-Host("Current Version: " + $global:DockingVersion)
                    Start-Process -Wait -FilePath "$PSScriptRoot\Treiber USB-C Docking Thunderbolt G4\HP_Dock_Thunderbolt_G4_Firmware\HPFirmwareInstaller.exe" -ArgumentList "-s"
                    HP_Docking_Info
                    write-host("Dockingstation has been updated.")
                    write-host("Dockingstation: " + $global:DockingProductName)
                    Write-Host("New Version: " + $global:DockingVersion)
                    }
                }
            Default {
                write-host("No matches")
            }
        }
    }
}

#endregion


#region check idle Time
Add-Type @'
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

namespace PInvoke.Win32 {

    public static class UserInput {

        [DllImport("user32.dll", SetLastError=false)]
        private static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

        [StructLayout(LayoutKind.Sequential)]
        private struct LASTINPUTINFO {
            public uint cbSize;
            public int dwTime;
        }

        public static DateTime LastInput {
            get {
                DateTime bootTime = DateTime.UtcNow.AddMilliseconds(-Environment.TickCount);
                DateTime lastInput = bootTime.AddMilliseconds(LastInputTicks);
                return lastInput;
            }
        }

        public static TimeSpan IdleTime {
            get {
                return DateTime.UtcNow.Subtract(LastInput);
            }
        }

        public static int LastInputTicks {
            get {
                LASTINPUTINFO lii = new LASTINPUTINFO();
                lii.cbSize = (uint)Marshal.SizeOf(typeof(LASTINPUTINFO));
                GetLastInputInfo(ref lii);
                return lii.dwTime;
            }
        }
    }
}
'@
#endregion

$startTimewindow = Get-Date '11:30'
$endTimewindow = Get-Date '13:30'

for ( $i = 0; $i -lt 900; $i++ ) {
    $now = Get-Date
    if($startTimewindow.TimeOfDay -le $now.TimeOfDay -and $endTimewindow.TimeOfDay -ge $now.TimeOfDay) {
        $idle_minutes = [PInvoke.Win32.UserInput]::IdleTime.Minutes
        $idle_Seconds = [PInvoke.Win32.UserInput]::IdleTime.Seconds
        if($idle_minutes -gt 12 ){
            Write-Host("---------------------------------------------------")
            Write-Host("Inactivety for more then 12 Minutes detected! Starting HP USB-C Docking Update if applicable")
            Write-Host ("Last input " + [PInvoke.Win32.UserInput]::LastInput.TimeOfDay.Hours + ":" +  [PInvoke.Win32.UserInput]::LastInput.TimeOfDay.Minutes)
            Write-Host ("Idle for " + [PInvoke.Win32.UserInput]::IdleTime.Minutes + " Minutes.")
            Write-Host("---------------------------------------------------")
            Update-HP_Docking
            robocopy "$PSScriptRoot\results\Worked" "C:\TEMP\_hotline" /E /NFL /NDL /NJH /NJS /nc /ns /np
            exit
        }
        Write-Host($idle_minutes)
        Start-Sleep -Seconds 6
    } else {
        write-host("Outside of allowed timewindow.")
        exit
    }
}

robocopy "$PSScriptRoot\results\Nope" "C:\TEMP\_hotline" /E /NFL /NDL /NJH /NJS /nc /ns /np
