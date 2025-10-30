Get-Service

#중지된 서비스만 보기
Get-Service | Where-Object {$_.status -eq "Stopped"}

#특정 서비스 제어
Restart-Service -Name Spooler
Stop-Service -Name W32Time
Start-Service -Name W32Time