workflow Get-BlacklistsResolveDNS {
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
            $DnsCheck = Resolve-DnsName -Name $FQDN -DnsOnly -ErrorAction 'SilentlyContinue' -NoHostsFile -QuickTimeout:$QuickTimeout # Impact of using -QuickTimeout unknown
            if ($null -ne $DnsCheck) {
                $ServerData = [PSCustomObject]  @{
                    IP        = $IP
                    FQDN      = $FQDN
                    BlackList = $Server
                    IsListed  = $true
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
            $WORKFLOW:Blacklisted += $ServerData
        }
    }
    return $WORKFLOW:Blacklisted
}