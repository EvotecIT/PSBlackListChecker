workflow Get-BlacklistsResolveDNS {
    [cmdletbinding()]
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
                    IsListed  = if ($null -eq $DNSCheck.IpAddress) { $false } else { $true }
                    Answer    = $DnsCheck.IPAddress -join ', '
                    TTL       = $DnsCheck.TTL -join ', '
                }
            } else {
                Write-Verbose -Message "DNSCheck - IS $NULL"
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