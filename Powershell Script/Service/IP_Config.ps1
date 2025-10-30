Write-Host "---Network Configuration Start---" -ForegroundColor Green

# Choose Network Adapter
Write-Host "Available Network Adapters:" -ForegroundColor Green
$Adapters = Get-NetAdapter | Where-Object {$_.Status -eq "UP"} 
$AdapterList = @()
foreach ($Adapter in $Adapters) {
    # IPv4 구성 정보
    $Config = Get-NetIPConfiguration -interfaceIndex $Adapter.ifIndex -ErrorAction SilentlyContinue

    $IPv4Address = $Config.IPv4address.IPv4Address
    $SubnetPrefix = $Config.IPv4Address.PrefixLength
    $Gateway = $Config.IPv4DefaultGateway.Nexthop
    $DNS = ($Config.DNSServer | Select-Object -ExpandProperty ServerAddresses) -join ', '

    $AdapterList += [PSCustomObject]@{
        IfIndex = $Adapter.ifIndex
        Name = $Adapter.Name
        Status = $Adapter.Status
        IPAddress = $IPv4Address
        Subnet = $SubnetPrefix
        Gateway = $Gateway
        DNS = $DNS
    }
}

$AdapterList | Format-Table -AutoSize

# Select Adapter
$InterfaceIndex = Read-Host "Enter the interface index of the adapter you want to configure (Ex: 23)"

# Check Adapter
$SelectAdapter = Get-NetAdapter -InterfaceIndex $InterfaceIndex -ErrorAction Stop
Write-Host "Selected Adapter: $($SelectAdapter.Name) (IfIndex: $($SelectAdapter.ifindex))"

# Input IP Configuration
Write-Host "--Network Configuration--" -ForegroundColor Green
$NewIP = Read-Host "Enter the new IP Address (Ex: 192.168.1.100)"
$Newsubnet = Read-Host "Enter the Subnet Prefix Length (Ex: 24, DIDR notation)"
$NewGateway = Read-Host "Enter the Default Gateway (Ex: 192.168.1.1)"
$NewDNS = Read-Host "Enter the DNS Server Addresses (comma separated for multiple, Ex: 8.8.8.8,168.126.63.1)"
$DNSList = $NewDNS -split ',' | ForEach-Object { $_.Trim() }

# Remove existing IP addresses
Write-Host "Removing existing IP addresses..." -ForegroundColor Yellow
Get-NetIPAddress -InterfaceIndex $InterfaceIndex | Where-Object {$_.AddressFamily -eq "IPv4" -and $_.PrefixLength -ne 128} | Remove-NetIPAddress -Confirm:$false

# Set New IP Address
Write-Host "Setting new IP address..." -ForegroundColor Green
New-NetIPAddress -interfaceIndex $InterfaceIndex `
                 -IPAddress $NewIP`
                 -PrefixLength $Newsubnet `
                 -DefaultGateway $NewGateway `
                 -Confirm:$false | Out-Null

# DNS Configuration
Write-Host "Setting DNS addresses..."
Set-DnsClientServerAddress -InterfaceIndex $InterfaceIndex `
                           -ServerAddresses $DNSList `
                           -Confirm:$false | Out-Null

Write-Host "---Network Configuration Completed---" -ForegroundColor Green
Write-Host "IP Address : $NewIP/$Newsubnet"
Write-Host "DefaultGateway : $NewGateway"
Write-Host "DNS : $NewDNS"

Write-Host "---Updated Network Configuration---" -foregroundColor Green
$FinalAdapter = Get-NetAdapter -InterfaceIndex $InterfaceIndex
$FinalConfig = Get-NetIPConfiguration -InterfaceIndex $InterfaceIndex

$FinalOutput = [PSCustomObject]@{
    Name = $FinalAdapter.Name
    Status = $FinalAdapter.Status
    IPAddress = $FinalConfig.IPv4Address.IPv4Address
    Subnet = $FinalConfig.IPv4Address.PrefixLength
    Gateway = $FinalConfig.IPv4DefaultGateway.Nexthop
    DNS = ($FinalConfig.DNSServer | Select-Object -ExpandProperty ServerAddresses) -join ', '
}

#최종 테이블 출력
$FinalOutput | Format-Table -AutoSize 
Write-Host "---Network Configuration End---" -ForegroundColor Green
