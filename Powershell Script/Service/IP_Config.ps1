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
        IPAddresss = $IPv4Address
        Subnet = $SubnetPrefix
        Gateway = $Gateway
        DNS = $DNS
    }
}

$AdapterList | Format-Table -AutoSize

# Select Adapter
$InterfaceIndex = Read-Host "Enter the interface index of the adapter you want to configure"

# Check Adapter
$SelectAdapter = Get-NetAdapter -InterfaceIndex $InterfaceIndex -ErrorAction Stop
Write-Host "Selected Adapter: $($SelectAdapter.Name) (IfIndex: $($SelectAdapter.ifindex))"
