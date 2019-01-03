$Script:ScriptBlockResolveDNSSlow = {
    param (
        [string[]] $Servers,
        [string[]] $IPs,
        [bool] $QuickTimeout,
        [bool] $Verbose,
        [string[]] $DNSServer = ''
    )
    if ($Verbose) {
        $verbosepreference = 'continue'
    }
    $Blacklisted = foreach ($Server in $Servers) {
        foreach ($IP in $IPS) {
            $ReversedIP = ($IP -split '\.')[3..0] -join '.'
            $FQDN = "$ReversedIP.$Server"
            if ($DNSServer -ne '') {
                $DnsCheck = Resolve-DnsName -Name $fqdn -ErrorAction SilentlyContinue -NoHostsFile -QuickTimeout:$QuickTimeout -Server $DNSServer -DnsOnly  # Impact of using -QuickTimeout unknown
            } else {
                $DnsCheck = Resolve-DnsName -Name $fqdn -ErrorAction SilentlyContinue -NoHostsFile -QuickTimeout:$QuickTimeout -DnsOnly
            }
            if ($null -ne $DnsCheck) {
                [PSCustomObject] @{
                    IP        = $IP
                    FQDN      = $FQDN
                    BlackList = $Server
                    IsListed  = if ($null -eq $DNSCheck.IpAddress) { $false } else { $true }
                    Answer    = $DnsCheck.IPAddress -join ', '
                    TTL       = $DnsCheck.TTL -join ', '
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
