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

# remove files
function Clear-Files($paths) {
    foreach ($path in $paths) {
        if (Test-Path $path) {
            Remove-Item -Path $path -Force -Recurse -ErrorAction SilentlyContinue
            Write-Host "Cleared: $path" -ForegroundColor Green
        }
    }
}

Write-Host "Starting system cleanup..." -ForegroundColor Cyan

Clear-Files $TempPaths
Clear-Files $BrowserPaths
Clear-Files $LogPaths

# Duplicate file removal
$TargetDir = Read-Host "Enter directory to check for duplicates"
if (Test-Path $TargetDir) {
    $Files = Get-ChildItem -Path $TargetDir -Recurse -File
    $HashTable = @{}

    foreach ($File in $Files) {
        $Hash = (Get-FileHash $File.FullName -Algorithm MD5).Hash
        if ($HashTable.ContainsKey($Hash)) {
            Remove-Item -Path $File.FullName -Force
            Write-Host "Deleted duplicate: $($File.FullName)" -ForegroundColor Yellow
        }
        else {
            $HashTable[$Hash] = $File.FullName
        }
    }
}

Write-Host "Cleanup complete!" -ForegroundColor Magenta
