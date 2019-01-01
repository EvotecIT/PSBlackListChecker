$Script:ScriptBlockResolveDNS = {
    param (
        [string] $Server,
        [string] $IP,
        [bool] $QuickTimeout,
        [bool] $Verbose
    )
    if ($Verbose) {
        $verbosepreference = 'continue'
    }
    [string] $ReversedIP = ($IP -split '\.')[3..0] -join '.'
    [string] $FQDN = "$ReversedIP.$Server"

    [int] $Count = 0
    [bool] $Loaded = $false
    Do {
        try {
            Import-Module -Name 'DnsClient'
            $Loaded = $true
        } catch {
            Write-Warning "DNSClient Import Error ($Server / $FQDN / $IP): $_. Retrying."
        }
        $Count++
        if ($Loaded -eq $false -and $Count -eq 5) {
            Write-Warning "DNSClient Import failed. Skipping check on $Server / $FQDN / $IP"
        }
    } until ($Loaded -eq $false -or $Count -eq 5)
    $DnsCheck = Resolve-DnsName -Name $fqdn -DnsOnly -ErrorAction 'SilentlyContinue' -NoHostsFile -QuickTimeout:$QuickTimeout # Impact of using -QuickTimeout unknown

    if ($null -ne $DnsCheck) {
        $ServerData = [PSCustomObject] @{
            IP        = $IP
            FQDN      = $FQDN
            BlackList = $Server
            IsListed  = if ($null -eq $DNSCheck.IpAddress) { $false } else { $true }
            Answer    = $DnsCheck.IPAddress -join ', '
            TTL       = $DnsCheck.TTL -join ', '
        }
    } else {
        $ServerData = [PSCustomObject]  @{
            IP        = $IP
            FQDN      = $FQDN
            BlackList = $Server
            IsListed  = $false
            Answer    = ''
            TTL       = ''
        }
    }
    return $ServerData
}