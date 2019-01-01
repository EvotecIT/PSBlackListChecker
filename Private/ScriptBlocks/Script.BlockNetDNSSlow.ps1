$Script:ScriptBlockNetDNSSlow = {
    param (
        [string[]] $Servers,
        [string[]] $IPs,
        [bool] $QuickTimeout,
        [bool] $Verbose
    )
    if ($Verbose) {
        $verbosepreference = 'continue'
    }

    $Blacklisted = foreach ($Server in $Servers) {
        foreach ($IP in $IPS) {
            $ReversedIP = ($IP -split '\.')[3..0] -join '.'
            $FQDN = "$ReversedIP.$Server"
            try {
                $DnsCheck = [Net.DNS]::GetHostAddresses($FQDN)
            } catch {
                $DnsCheck = $null
            }
            if ($null -ne $DnsCheck) {
                [PSCustomObject] @{
                    IP        = $ip
                    FQDN      = $fqdn
                    BlackList = $server
                    IsListed  = if ($null -eq $DNSCheck.IPAddressToString) { $false } else { $true }
                    Answer    = $DnsCheck.IPAddressToString -join ', '
                    TTL       = ''
                }
            } else {
                [PSCustomObject] @{
                    IP        = $IP
                    FQDN      = $FQDN
                    BlackList = $Server
                    IsListed  = $false
                    Answer    = ''
                    TTL       = ''
                }
            }
        }
    }
    return $Blacklisted
}