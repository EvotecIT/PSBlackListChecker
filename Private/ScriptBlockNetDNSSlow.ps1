$ScriptBlockNetDNSSlow = {
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
        try {
            $DnsCheck = [Net.DNS]::GetHostAddresses($fqdn)

        } catch { $DnsCheck = $null }
        if ($DnsCheck -ne $null) {
            $ServerData = @{
                IP        = $ip
                FQDN      = $fqdn
                BlackList = $server
                IsListed  = $true
                Answer    = $DnsCheck.IPAddressToString -join ', '
                TTL       = ''
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