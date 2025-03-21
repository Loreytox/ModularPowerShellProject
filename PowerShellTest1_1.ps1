param(
    [string]$SourcePath = ".",
    [string]$DestinationPath = ".",
    [string]$FileName = "*", # Use for matching file names, for example "LA_1703"
    [string]$Extension = "*", # Use for file extensions, for example ".txt", ".csv", ".jpg" etc.
    [long]$MinFileSize = 0, # Set Minimum file size in bytes
    [long]$MaxFileSize = [long]::MaxValue, # Set Maximum file size in bytes
    [datetime]$CreatedAfter = "01/01/1900", # Search for only files created after this date
    [datetime]$CreatedBefore = [datetime]::MaxValue # Search for only files created before this date
)

$files = Get-ChildItem -Path $SourcePath -Recurse -File |
Where-Object {
        ($_.Name -like $FileName) -and
        ($_.Extension -like $Extension) -and
        ($_.Length -ge $MinFileSize) -and
        ($_.Length -le $MaxFileSize) -and
        ($_.CreationTime -ge $CreatedAfter) -and
        ($_.CreationTime -le $CreatedBefore)
}

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
    }
    else {
        Move-Item -Path $file.FullName -Destination $dest
    }
}

Get-ChildItem -Path $SourcePath -Directory |
Where-Object { (Get-ChildItem $_ -Recurse -File).count -eq 0 } |
ForEach-Object { Remove-Item $_ -Recurse }

Write-Host "Operation completed. Moved $($files.Count) file(s)."
