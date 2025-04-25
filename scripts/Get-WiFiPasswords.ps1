# Check if running as Admin
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: You need to run this as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator', then try again."
    exit
}

Write-Host "`nFinding Wi-Fi networks..." -ForegroundColor Yellow
$wifiList = netsh wlan show profiles

# Extract Wi-Fi names
$wifiNames = @()
foreach ($line in $wifiList -split "`n") {
    if ($line -like "*All User Profile*") {
        $name = $line -replace ".*All User Profile\s*:\s*", ""
        $wifiNames += $name.Trim()
    }
}

Write-Host "`nFound these Wi-Fi networks:`n" -ForegroundColor Green
foreach ($wifi in $wifiNames) {
    # Gets the key
    $wifiDetails = netsh wlan show profile name="$wifi" key=clear

    $password = "N/A (Open Network)"
    foreach ($detail in $wifiDetails -split "`n") {
        if ($detail -like "*Key Content*") {
            $password = $detail -replace ".*Key Content\s*:\s*", ""
            $password = $password.Trim()
        }
    }

    Write-Host "Wi-Fi Name: $wifi"
    Write-Host "Password  : $password`n"
}

# Pause
Write-Host "Done! Press Enter to exit..." -ForegroundColor Cyan
Read-Host