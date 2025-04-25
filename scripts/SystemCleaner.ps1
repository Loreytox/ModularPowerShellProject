$TempPaths = @(
    "$env:TEMP\*",
    "$env:USERPROFILE\AppData\Local\Temp\*",
    "$env:SystemRoot\Temp\*"
)

$BrowserPaths = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*",
    "$env:APPDATA\Mozilla\Firefox\Profiles\*\cache2\entries\*"
)

$LogPaths = @(
    "$env:USERPROFILE\AppData\Local\Microsoft\Windows\INetCache\*",
    "$env:USERPROFILE\AppData\Local\CrashDumps\*",
    "$env:SystemRoot\Logs\*"
)

$DeletedFiles = @()

# Remove and track items
function Clear-Files($paths, $DryRun = $false) {
    foreach ($path in $paths) {
        if (Test-Path $path) {
            $files = Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue
            foreach ($file in $files) {
                if ($DryRun) {
                    Write-Host "Would delete: $($file.FullName)" -ForegroundColor Yellow
                }
                else {
                    try {
                        Remove-Item -Path $file.FullName -Force -Recurse
                        $DeletedFiles += $file.FullName
                    }
                    catch {
                        Write-Warning "Failed to delete: $($file.FullName)"
                    }
                }
            }
        }
    }
}

Write-Host "Starting system cleanup..." -ForegroundColor Cyan

# Ask if the user wants to perform a dry run
$DryRunInput = Read-Host "Enable dry run mode? (yes/no)"
$DryRun = $DryRunInput -eq "yes"

Clear-Files $TempPaths $DryRun
Clear-Files $BrowserPaths $DryRun
Clear-Files $LogPaths $DryRun

# Ask for duplicates
$TargetDir = Read-Host "Enter directory to check for duplicates (leave blank to skip)"
if (-not [string]::IsNullOrWhiteSpace($TargetDir)) {
    if (Test-Path $TargetDir) {
        $Files = Get-ChildItem -Path $TargetDir -Recurse -File
        $HashTable = @{}

        foreach ($File in $Files) {
            $Hash = (Get-FileHash $File.FullName -Algorithm MD5).Hash
            if ($HashTable.ContainsKey($Hash)) {
                if ($DryRun) {
                    Write-Host "Would delete duplicate: $($File.FullName)" -ForegroundColor Yellow
                }
                else {
                    try {
                        Remove-Item -Path $File.FullName -Force
                        $DeletedFiles += $File.FullName
                    }
                    catch {
                        Write-Warning "Failed to delete duplicate: $($File.FullName)"
                    }
                }
            }
            else {
                $HashTable[$Hash] = $File.FullName
            }
        }
    }
    else {
        Write-Host "Invalid directory path provided. Skipping duplicate check..." -ForegroundColor Red
    }
}

# Display all deleted files
if (-not $DryRun) {
    Write-Host "`nCleanup complete! Deleted files:" -ForegroundColor Magenta
    if ($DeletedFiles.Count -gt 0) {
        $DeletedFiles | ForEach-Object { Write-Host $_ -ForegroundColor Green }
    }
    else {
        Write-Host "No files were deleted." -ForegroundColor Yellow
    }
    else {
        Write-Host "`nDry run complete! No files were deleted." -ForegroundColor Cyan
    }
}