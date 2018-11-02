$Script:ScriptBlockResolveDNSSlow = {
    param (
        [string[]] $Servers,
        [string[]] $IPs,
        [bool] $QuickTimeout,
        [bool] $Verbose
    )
    if ($Verbose) {
        $verbosepreference = 'continue'
    }
    $Blacklisted = @()
    foreach ($Server in $Servers) {
        foreach ($IP in $IPS) {
            $ReversedIP = ($IP -split '\.')[3..0] -join '.'
            $FQDN = "$ReversedIP.$Server"
            $DnsCheck = Resolve-DnsName -Name $fqdn -DnsOnly -ErrorAction 'SilentlyContinue' -NoHostsFile -QuickTimeout:$QuickTimeout # Impact of using -QuickTimeout unknown
            if ($null -ne $DnsCheck) {
                $Blacklisted += [PSCustomObject] @{
                    IP        = $IP
                    FQDN      = $FQDN
                    BlackList = $Server
                    IsListed  = if ($null -eq $DNSCheck.IpAddress) { $false } else { $true }
                    Answer    = $DnsCheck.IPAddress -join ', '
                    TTL       = $DnsCheck.TTL -join ', '
                }
            } else {
                $Blacklisted += [PSCustomObject] @{
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
