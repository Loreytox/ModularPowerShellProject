# Config - MUST be at top of script
$logDir = Join-Path -Path $PSScriptRoot -ChildPath "../logs"
$logFile = Join-Path -Path $logDir -ChildPath "audit_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"

# Ensure logs directory exists
if (-not (Test-Path -Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

function Get-StartupItems {
    $startup = @()
    $sources = @(
        "Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run",
        "Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run",
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup",
        "$env:PROGRAMDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    )

    foreach ($source in $sources) {
        try {
            if ($source -like "Registry::*") {
                $regPath = $source -replace "Registry::", ""
                $regValues = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue
                
                if ($regValues) {
                    $regValues.PSObject.Properties | Where-Object {
                        $_.Name -notmatch '^PS' -and $_.Name -ne '(default)'
                    } | ForEach-Object {
                        $startup += [PSCustomObject]@{
                            Name   = $_.Name
                            Path   = $_.Value
                            Source = "Registry: $regPath"
                        }
                    }
                }
            }
            else {
                if (Test-Path $source) {
                    Get-ChildItem -Path $source -Filter *.lnk -ErrorAction SilentlyContinue | ForEach-Object {
                        $startup += [PSCustomObject]@{
                            Name   = $_.Name
                            Path   = $_.FullName
                            Source = "Startup Folder"
                        }
                    }
                }
            }
        }
        catch {
            Write-Warning ("Failed to query {0}: {1}" -f $source, $_.Exception.Message)
        }
    }
    return , $startup
}

function Get-SystemHardware {
    try {
        $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
        $processor = Get-CimInstance -ClassName Win32_Processor | Select-Object -First 1
        $memory = [math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)
        $disks = Get-CimInstance -ClassName Win32_DiskDrive | ForEach-Object {
            [PSCustomObject]@{
                Model  = $_.Model
                SizeGB = [math]::Round($_.Size / 1GB, 2)
            }
        }

        return [PSCustomObject]@{
            Manufacturer = $computerSystem.Manufacturer
            Model        = $computerSystem.Model
            CPU          = $processor.Name
            MemoryGB     = $memory
            Disks        = @($disks)
        }
    }
    catch {
        Write-Warning "Hardware data fetch failed: $($_.Exception.Message)"
        return [PSCustomObject]@{ Error = "Hardware query error" }
    }
}

# Main execution
try {
    $auditData = [PSCustomObject]@{
        Timestamp    = Get-Date -Format "o"
        System       = Get-SystemHardware
        OS           = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
        BIOS         = (Get-CimInstance -ClassName Win32_BIOS).SMBIOSBIOSVersion
        Network      = @(Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter "IPEnabled=True" | 
            Select-Object Description, MACAddress, IPAddress)
        GPU          = Get-CimInstance -ClassName Win32_VideoController | 
        Select-Object Name, AdapterRAM, DriverVersion
        StartupItems = @(Get-StartupItems)
    }

    $jsonOutput = $auditData | ConvertTo-Json -Depth 5 -Compress
    $jsonOutput | Out-File -FilePath $logFile -Encoding utf8 -Force

    Write-Host "System audit saved to: $logFile" -ForegroundColor Green
    $auditData | ConvertTo-Json -Depth 3

}
catch {
    Write-Error "Script failed: $($_.Exception.Message)"
    exit 1
}