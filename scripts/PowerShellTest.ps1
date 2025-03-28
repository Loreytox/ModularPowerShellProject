# Function to get a valid folder path from the user
function Get-ValidPath($PromptMessage) {
    do {
        $Path = Read-Host $PromptMessage
        if (!(Test-Path $Path -PathType Container)) {
            Write-Host "Invalid path. Please enter a valid directory." -ForegroundColor Red
        }
    } while (!(Test-Path $Path -PathType Container))
    return $Path
}


$SourcePath = Get-ValidPath "Enter the source folder path"

# Get destination path with folder creation option
$DestinationPath = Read-Host "Enter the destination folder path"
if (!(Test-Path $DestinationPath -PathType Container)) {
    $Create = Read-Host "Destination does not exist. Create it? (Y/N)"
    if ($Create -match "[Yy]") {
        New-Item -Path $DestinationPath -ItemType Directory | Out-Null
        Write-Host "Folder created: $DestinationPath" -ForegroundColor Green
    }
    else {
        Write-Host "Operation aborted." -ForegroundColor Red
        exit
    }
}

$FileName = Read-Host "Enter the file name pattern (e.g., 'LA_1703' or '*' for all)"
$Extension = Read-Host "Enter the file extension (e.g., '.txt', '.csv', '.jpg', or '*' for all)"
$MinFileSize = Read-Host "Enter the minimum file size in bytes (default: 0)"
$MinFileSize = if ($MinFileSize -match '^\d+$') { [long]$MinFileSize } else { 0 }
$MaxFileSize = Read-Host "Enter the maximum file size in bytes (default: unlimited)"
$MaxFileSize = if ($MaxFileSize -match '^\d+$') { [long]$MaxFileSize } else { [long]::MaxValue }
$CreatedAfter = Read-Host "Enter the creation date after (MM/DD/YYYY, default: 01/01/1900)"
$CreatedAfter = if ($CreatedAfter -match '^\d{2}/\d{2}/\d{4}$') { [datetime]$CreatedAfter } else { [datetime]"01/01/1900" }
$CreatedBefore = Read-Host "Enter the creation date before (MM/DD/YYYY, default: today)"
$CreatedBefore = if ($CreatedBefore -match '^\d{2}/\d{2}/\d{4}$') { [datetime]$CreatedBefore } else { [datetime]::MaxValue }

# Find files
$files = Get-ChildItem -Path $SourcePath -Recurse -File | Where-Object {
    ($_.Name -like $FileName) -and
    ($_.Extension -like $Extension) -and
    ($_.Length -ge $MinFileSize) -and
    ($_.Length -le $MaxFileSize) -and
    ($_.CreationTime -ge $CreatedAfter) -and
    ($_.CreationTime -le $CreatedBefore)
}

Write-Host "Found $($files.Count) matching file(s). Moving files..." -ForegroundColor Cyan


$loadingFrames = @("\", "|", "/", "-")
$frameIndex = 0


$startTime = Get-Date

# Move files with loading animation
$i = 0
foreach ($file in $files) {
    $i++
    $frame = $loadingFrames[$frameIndex]
    Write-Host "`r$frame Moving file $i of $($files.Count)..." -NoNewline
    $frameIndex = ($frameIndex + 1) % $loadingFrames.Count

    Start-Sleep -Milliseconds 100  # Small delay to show animation

    $dest = Join-Path $DestinationPath $file.Name
    if (Test-Path $dest) {
        $count = 1
        do {
            $newName = "$($file.BaseName)_$count$($file.Extension)"
            $newDest = Join-Path $DestinationPath $newName
            $count++
        } while (Test-Path $newDest)
        Move-Item -Path $file.FullName -Destination $newDest
    }
    else {
        Move-Item -Path $file.FullName -Destination $dest
    }
}

while ((New-TimeSpan -Start $startTime).TotalSeconds -lt 3) {
    $frame = $loadingFrames[$frameIndex]
    Write-Host "`r$frame Finalizing..." -NoNewline
    $frameIndex = ($frameIndex + 1) % $loadingFrames.Count
    Start-Sleep -Milliseconds 200
}

Write-Host "`ro Operation completed. Moved $($files.Count) file(s)." -ForegroundColor Magenta