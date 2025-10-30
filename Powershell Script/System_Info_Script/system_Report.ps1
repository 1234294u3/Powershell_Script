# 이벤트 뷰어 실행
if (-not (Get-Process -Name eventvwr -ErrorAction SilentlyContinue)) {
    start-Process -FilePath eventvwr.msc
}


# 시스템 정보 및 디스크 사용량 수집/출력
$computer = Get-ComputerInfo | Select-Object CsName, OsName, OsVersion
$drives = Get-Volume | Where-Object {$_.DriveLetter} | Select-Object `
    DriveLetter,
    FileSystemType,
    @{Name='Size(GB)'; Expression={[math]::Round($_.Size/1GB, 2)}},
    @{Name='SizeRemaining(GB)'; Expression={[math]::Round($_.SizeRemaining/1GB, 2)}},
    @{Name='Used(%)'; Expression={[math]::Round((($_.Size - $_.SizeRemaining) / $_.Size) * 100, 2)}},
    @{Name='Free(%)'; Expression={[math]::Round(($_.SizeRemaining / $_.Size) * 100, 2)}}
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Output "----System Report----"
Write-Output "Date : $date"
Write-Output "HostName : $($computer.CsName)"
Write-Output "Operating System : $($computer.OsName) 버전 $($computer.OsVersion)"
Write-Output "Disk Usage :"
Write-Output $drives | Format-Table -AutoSize

# CPU 사용량 및 RAM 사용량 수집/출력
# CPU 사용량 수집 (10초)
Write-Host "CPU usage collection... (10초)" -ForegroundColor Yellow
$cpuSamples = Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 10
$avgCPU = [math]::Round(($cpuSamples.CounterSamples | Measure-Object -Property CookedValue -Average).Average, 2)

# RAM 정보
$os = Get-CimInstance Win32_OperatingSystem

# 결과 출력
Write-Host "[CPU & RAM Summary]" -ForegroundColor Cyan
[PSCustomObject]@{
    Name = "[CPU & RAM Summary]"
    'CPU Used' = "$avgCPU%"
    'RAM Total(GB)' = [math]::Round($os.TotalVisibleMemorySize/1MB, 2)
    'RAM Used(GB)' = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory)/1MB, 2)
    'RAM Used(%)' = "$([math]::Round((($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize) * 100, 2))%"
} | Format-List
Read-Host "`nPress Enter to exit..."

