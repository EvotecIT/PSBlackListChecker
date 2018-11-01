$Script:ScriptBlockNetDNS = {
    param (
        [string] $Server,
        [string] $IP,
        [bool] $QuickTimeout,
        [bool] $Verbose
    )
    if ($Verbose) {
        $verbosepreference = 'continue'
    }
    $ReversedIP = ($IP -split '\.')[3..0] -join '.'
    $FQDN = "$ReversedIP.$Server"
    try {
        $DnsCheck = [Net.DNS]::GetHostAddresses($fqdn)
    } catch { $DnsCheck = $null }
    if ($DnsCheck -ne $null) {
        $ServerData = [PSCustomObject] @{
            IP        = $IP
            FQDN      = $FQDN
            BlackList = $Server
            IsListed  = $true
            Answer    = $DnsCheck.IPAddressToString -join ', '
            TTL       = ''
        }
    } else {
        $ServerData = [PSCustomObject] @{
            IP        = $IP
            FQDN      = $FQDN
            BlackList = $Server
            IsListed  = $false
            Answer    = $DnsCheck.IPAddress
            TTL       = ''
        }
    }

    return $ServerData
}