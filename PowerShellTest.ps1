# Read-Host for user-input instead of cmdlets
$SourcePath = Read-Host "Enter the source folder path"
while (!(Test-Path $SourcePath -PathType Container)) {
    Write-Host "Invalid path. Please enter a valid source folder." -ForegroundColor Red
    $SourcePath = Read-Host "Enter the source folder path"
}

$DestinationPath = Read-Host "Enter the destination folder path"
while (!(Test-Path $DestinationPath -PathType Container)) {
    Write-Host "Invalid path. Please enter a valid destination folder." -ForegroundColor Red
    $DestinationPath = Read-Host "Enter the destination folder path"
}

$FileName = Read-Host "Enter the file name pattern (e.g., 'LA_1703' or '*' for all)"
$Extension = Read-Host "Enter the file extension (e.g., '.txt', '.csv', '.jpg', or '*' for all)"

$MinFileSize = Read-Host "Enter the minimum file size in bytes (default: 0)"
if ($MinFileSize -match '^\d+$') { $MinFileSize = [long]$MinFileSize } else { $MinFileSize = 0 }

$MaxFileSize = Read-Host "Enter the maximum file size in bytes (default: unlimited)"
if ($MaxFileSize -match '^\d+$') { $MaxFileSize = [long]$MaxFileSize } else { $MaxFileSize = [long]::MaxValue }

$CreatedAfter = Read-Host "Enter the creation date after (format: MM/DD/YYYY, default: 01/01/1900)"
if ($CreatedAfter -match '^\d{2}/\d{2}/\d{4}$') { $CreatedAfter = [datetime]$CreatedAfter } else { $CreatedAfter = [datetime]"01/01/1900" }

$CreatedBefore = Read-Host "Enter the creation date before (format: MM/DD/YYYY, default: today)"
if ($CreatedBefore -match '^\d{2}/\d{2}/\d{4}$') { $CreatedBefore = [datetime]$CreatedBefore } else { $CreatedBefore = [datetime]::MaxValue }

# Filter files based on user-defined criteriaa
$files = Get-ChildItem -Path $SourcePath -Recurse -File |
Where-Object {
    ($_.Name -like $FileName) -and
    ($_.Extension -like $Extension) -and
    ($_.Length -ge $MinFileSize) -and
    ($_.Length -le $MaxFileSize) -and
    ($_.CreationTime -ge $CreatedAfter) -and
    ($_.CreationTime -le $CreatedBefore)
}

Write-Host "Found $($files.Count) matching file(s). Moving files..." -ForegroundColor Cyan

foreach ($file in $files) {
    $dest = Join-Path $DestinationPath $file.Name
    if (Test-Path $dest) {
        $i = 1
        do {
            $newName = "$($file.BaseName)_$i$($file.Extension)"
            $newDest = Join-Path $DestinationPath $newName
            $i++
        } while (Test-Path $newDest)
        Move-Item -Path $file.FullName -Destination $newDest
        Write-Host "Moved: $($file.Name) -> $newName" -ForegroundColor Green
    }
    else {
        Move-Item -Path $file.FullName -Destination $dest
        Write-Host "Moved: $($file.Name)" -ForegroundColor Green
    }
}

Get-ChildItem -Path $SourcePath -Directory |
Where-Object { (Get-ChildItem $_ -Recurse -File).count -eq 0 } |
ForEach-Object { 
    Remove-Item $_ -Recurse
    Write-Host "Deleted empty folder: $($_.FullName)" -ForegroundColor Yellow
}

Write-Host "`nOperation completed. Moved $($files.Count) file(s)." -ForegroundColor Magenta
