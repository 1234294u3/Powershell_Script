$Date = Get-Date -Format "yyyy-MM-dd"
$BackupPath = "C:\Backup\$Date"
if (-not (Test-Path $BackupPath)) {
    New-Item -Path $BackupPath -ItemType Directory | Out-Null
}

# Log_Collect
function Save-EventLog {
    param (
        [string]$LogName,
        [string]$FileName
    )
        # Level 1=Critical, 2=Error, 3=Warning
        $Levels = @(1,2,3)
        Get-WinEvent -FilterHashtable @{LogName=$LogName; Level=$Levels} | 
        Select-Object TimeCreated, Id, LevelDisplayName, Message |
        Export-Csv "$BackupPath\$FileName" -NoTypeInformation -Encoding utf8BOM
}

Save-EventLog -Logname "System" -FileName "{$Date} System_Log.csv"
Save-EventLog -Logname "Application" -FileName "{$Date} Application_Log.csv"
Save-EventLog -Logname "Security" -FileName "{$Date} Security_Log.csv"

Write-Output "[$Date] Success Collected Event Logs to $BackupPath"
