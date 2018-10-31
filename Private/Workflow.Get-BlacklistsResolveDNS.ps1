workflow Get-BlacklistsResolveDNS {
    param (
        [string[]] $BlacklistServers,
        [string[]] $Ips,
        [bool] $QuickTimeout
    )
    $blacklistedOn = @()
    foreach -parallel ($server in $BlacklistServers) {
        #foreach ($server in $BlackLists) {
        foreach ($ip in $ips) {
            $reversedIP = ($IP -split '\.')[3..0] -join '.'
            $fqdn = "$reversedIP.$server"
            $DnsCheck = Resolve-DnsName -Name $fqdn -DnsOnly -ErrorAction 'SilentlyContinue' -NoHostsFile -QuickTimeout:$QuickTimeout # Impact of using -QuickTimeout unknown
            if ($DnsCheck -ne $null) {
                $ServerData = @{
                    IP        = $ip
                    FQDN      = $fqdn
                    BlackList = $server
                    IsListed  = $true
                    Answer    = $DnsCheck.IPAddress -join ', '
                    TTL       = $DnsCheck.TTL
                }
            } else {
                $ServerData = @{
                    IP        = $ip
                    FQDN      = $fqdn
                    BlackList = $server
                    IsListed  = $false
                    Answer    = $DnsCheck.IPAddress
                    TTL       = ''
                }
            }
            $WORKFLOW:blacklistedOn += $ServerData
        }
    }
    return $WORKFLOW:blacklistedOn
}