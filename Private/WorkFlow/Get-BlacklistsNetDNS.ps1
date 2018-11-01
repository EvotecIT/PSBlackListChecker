workflow Get-BlacklistsNetDNS {
    param (
        [string[]] $BlacklistServers,
        [string[]] $Ips,
        [bool] $QuickTimeout
    )
    $Blacklisted = @()
    foreach -parallel ($Server in $BlacklistServers) {
        foreach ($IP in $Ips) {
            $ReversedIP = ($IP -split '\.')[3..0] -join '.'
            $FQDN = "$ReversedIP.$Server"
            try {
                $DnsCheck = [Net.DNS]::GetHostAddresses($FQDN)
            } catch { $DnsCheck = $null }
            if ($null -ne $DnsCheck) {
                $ServerData = [PsCustomObject] @{
                    IP        = $IP
                    FQDN      = $FQDN
                    BlackList = $Server
                    IsListed  = $true
                    Answer    = $DnsCheck.IPAddress -join ', '
                    TTL       = $DnsCheck.TTL
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
            $WORKFLOW:Blacklisted += $ServerData
        }
    }
    return $WORKFLOW:Blacklisted
}