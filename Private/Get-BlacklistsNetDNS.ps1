workflow Get-BlacklistsNetDNS {
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
            try {
                $DnsCheck = [Net.DNS]::GetHostAddresses($fqdn)
            } catch { $DnsCheck = $null }
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