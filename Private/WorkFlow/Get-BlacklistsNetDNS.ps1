workflow Get-BlacklistsNetDNS {
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
            try {
                $DnsCheck = [Net.DNS]::GetHostAddresses($FQDN)
            } catch {
                $DnsCheck = $null
            }
            #Write-Verbose "PSBlackListChecker [WorkFlow.Get-BlacklistsNetDNS] - Server: $Server Ip: $IP FQDN: $FQDN Response: $($DnsCheck.IPAddressToString)"
            if ($null -ne $DnsCheck) {
                $ServerData = [PsCustomObject] @{
                    IP        = $IP
                    FQDN      = $FQDN
                    BlackList = $Server
                    IsListed  = if ($null -eq $DNSCheck.IPAddressToString) { $false } else { $true }
                    Answer    = $DnsCheck.IPAddressToString -join ', '
                    TTL       = $DnsCheck.TTL -join ', '
                }
            } else {
                $ServerData = [PSCustomObject] @{
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