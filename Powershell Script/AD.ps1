#로컬 사용자 목록(AD는 ADUser 사용)
Get-LocalUser
#새 사용자 생성 (AD는 ADUser)
New-LocalUser -Name "TestUser" -Password (ConvertFrom-SecureString "1234" -AsPlainText -Force)
#그룹 추가 (AD는 ADGroup)
Add-LocalGroupMember -Group "Administrators" -Member "TestUser"
#사용자 삭제 (AD는 Remove-ADUser)
Remove-LocalUser -Name "TestUser"