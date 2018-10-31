$ScriptBlockResolveDNSSlow = {
    param (
        [string[]] $Servers,
        [string] $IP,
        [bool] $QuickTimeout,
        [bool] $Verbose
    )
    if ($Verbose) {
        $verbosepreference = 'continue'
    }
    $BlacklistedOn = @()
    foreach ($Server in $Servers) {

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
        $BlackListedOn += $ServerData

    }
    return $BlacklistedOn
}
