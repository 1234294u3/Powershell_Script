# 서버 정보 확인
$serverinfo = Get-ComputerInfo | Select-Object CsName, OsName, OsVersion
$SerialNumber = (Get-CimInstance Win32_BIOS).SerialNumber
$Uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
$LastLogonEvent = Get-WinEvent -LogName Security -FilterHashTable @{
        id = 4624
        LogonType = 2 # 대화형(Interactive) 로그온 이벤트
} 


# 출력 --------------------------
Write-Host "----------------------------------------" -ForegroundColor Green
Write-Host "             서버 정보 요약" -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Green

"Server Name: {0}" -f $serverinfo.CsName
"OS Name: {0}" -f $serverinfo.OsName
"OS Version: {0}" -f $serverinfo.OsVersion
"Serial Number: {0}" -f $SerialNumber , ""

# 마지막 부팅 날짜
"Last Boot Up Time: {0}" -f (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
# 시스템 가동 시간
$Uptime | Select-Object @{
    Name = "Total Uptime"
    Expression = {
        $TotalDays = $_.Days
        $Years = [Math]::Floor($TotalDays / 365.25)
        $Months = [Math]::Floor(($TotalDays % 365.25) / 30.4375)
        $RemainingDays = [Math]::Floor(($TotalDays % 365.25) % 30.4375)

        "{0} Years {1} Months {2} Days {3} Hours {4} Minutes" -f $Years, $Months, $RemainingDays, $_.Hours, $_.Minutes
    }
}