$Date = (Get-Date -Format "yyyy-MM-dd")
$BackupRoot = "C:\Backup"
$BackupPath = Join-Path $BackupRoot $Date

if (-not (Test-Path $BackupPath)) {
    New-Item -ItemType Directory -Path $BackupPath
    Write-Output "[$Date] Success Created Backup Directory : $BackupPath"
} else {
    Write-Output "[$Date] Backup Directory Already Exists : $BackupPath"
}
