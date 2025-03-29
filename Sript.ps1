# Variable settings
$HostUrl = "http://localhost:8200" # Change to your Duplicati server URL
$Password = "password" # Change to your password
$ExportPath = "C:\DuplicatiBackups" # Change to the export path
$DuplicatiPath = "C:\Program Files\Duplicati 2\Duplicati.CommandLine.ServerUtil.exe" # Correct path on Windows

# Create the export directory if it doesn't exist
if (!(Test-Path -Path $ExportPath)) {
    New-Item -ItemType Directory -Path $ExportPath | Out-Null
}

# Change the current working directory to export path. Create if needed.
if (!(Test-Path -Path $ExportPath)) {
    try {
        New-Item -ItemType Directory -Path $ExportPath | Out-Null
    }
    catch {
        Write-Error "Failed to create directory '$ExportPath': $($_.Exception.Message)"
        return
    }
}

# Login to Duplicati server
try {
    & "$DuplicatiPath" login --password="$Password" --hosturl="$HostUrl"
}
catch {
    Write-Error "Login error: $($_.Exception.Message)"
    return
}

# Export backups with IDs 0 to 20
for ($i = 0; $i -le 20; $i++) {
    try {
        $exportFilePath = Join-Path -Path $ExportPath -ChildPath "Backup_$i.json"
        & "$DuplicatiPath" export "$i" --export-passwords=true --unencrypted
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Failed to export backup with ID $i."
        } else {
            Write-Host "Backup with ID $i exported to '$exportFilePath'."
        }
    }
    catch {
        Write-Error "Error exporting backup with ID ${i}: $($_.Exception.Message)"
    }
}
