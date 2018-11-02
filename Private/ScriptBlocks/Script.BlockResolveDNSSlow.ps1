$Script:ScriptBlockResolveDNSSlow = {
    param (
        [string[]] $Servers,
        [string] $IP,
        [bool] $QuickTimeout,
        [bool] $Verbose
    )
    if ($Verbose) {
        $verbosepreference = 'continue'
    }
    $Blacklisted = @()
    foreach ($Server in $Servers) {

        $ReversedIP = ($IP -split '\.')[3..0] -join '.'
        $FQDN = "$ReversedIP.$Server"
        $DnsCheck = Resolve-DnsName -Name $fqdn -DnsOnly -ErrorAction 'SilentlyContinue' -NoHostsFile -QuickTimeout:$QuickTimeout # Impact of using -QuickTimeout unknown
        if ($null -ne $DnsCheck) {
            $ServerData = [PSCustomObject] @{
                IP        = $IP
                FQDN      = $FQDN
                BlackList = $Server
                IsListed  = if ($null -eq $DNSCheck.IpAddress) { $false } else { $true }
                Answer    = $DnsCheck.IPAddress -join ', '
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
        $Blacklisted += $ServerData

    }
    return $Blacklisted
}
