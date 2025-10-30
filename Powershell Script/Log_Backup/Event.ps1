#System 로그에서 에러 단계의 새로운 로그 10개 출력
Get-EventLog -LogName System -EntryType Error -Newest 10
#Security 로그에서 에러 단계의 위에서 10개 출력
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4624} | Select TimeCreated, Id, Message -First 10
#결과를 CSV로 저장
Get-EventLog -LogName Application -Newest 20 | Export-Csv "C:\users\김민석\Desktop\Logs\Logs3.csv" -NoTypeInformation -Encoding utf8BOM