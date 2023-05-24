#region Get Information about currently connected Dockingstation
function Get-HP_Docking_Info{
    #Install HPDockWMIProvider to enable reading out Information from HP Dockingstations
    if (!(Test-Path  'C:\ProgramData\HP\HP_DockAccessory')) {

        Start-Process -Wait -FilePath "$PSScriptRoot\HPDockWMIProvider.exe" -ArgumentList "/S /v/qn"

        Write-Host("HPDockWMIProvider has been installed.")
        Start-Sleep -Seconds 3
        } 

    Write-Host("HPDockWMIProvider already installed.")

    $namespace = "ROOT\HP\InstrumentedServices\v1"

    $classname = "HP_DockAccessory"

    $global:DockingProductName = Get-WmiObject -Class $classname -Namespace $namespace | Select-Object -expandproperty ProductName
    $global:DockingVersion = Get-WmiObject -Class $classname -Namespace $namespace | Select-Object -expandproperty firmwarepackageversion

    $Dockin1 = Get-WmiObject -Class $classname -Namespace $namespace  
}
#endregion

Get-HP_Docking_Info
if ($global:DockingProductName -ne $null) {
    switch ($global:DockingProductName)
    {
        "HP USB-C Dock G5" {
            $Output_Docking = "HP_G5" + "_" + $global:DockingVersion
            Write-Host("HP USB-C Dock G5")
            }
        "HP USB-C/A Universal Dock G2" {
            $Output_Docking = "HP_Universal_Dock_G2" + "_" + $global:DockingVersion
            Write-Host("HP USB-C/A Universal Dock G2")            
            }
        "HP Thunderbolt Dock G4" {
            $Output_Docking = "HP_Thunderbolt_Dock_G4" + "_" + $global:DockingVersion
            Write-Host("HP Thunderbolt Dock G4")            
            }
        Default {
            $Output_Docking = "unknown_device"
            Write-Host("Unknown hp docking device")
        }
    }
} else {
    Write-Host("No matches")
    exit
    }

$output = ("Dockingstation: " + $global:DockingProductName + "`n"  +"Version: " + $global:DockingVersion)

$current_date = Get-Date -Format "dd/MM/yyyy"
$filepath = "\\process.bruggnet.com\dfs\Software\SCCMPKG\Scripts\Reports_Connected_USB-C_Docking\" + $Output_Docking + "_" + $env:computername +".txt"

if (Test-Path $filepath -PathType Leaf){
   Remove-Item -Path $filepath
} 
$user = "unknown"
$user = ((gwmi win32_computersystem).username).split('\')[1]
$output | Out-File -FilePath $filepath
Start-Sleep -Seconds 5
$user | Add-Content -path $filepath

Write-Host($output)
