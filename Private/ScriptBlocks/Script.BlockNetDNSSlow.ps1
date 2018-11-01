$Script:ScriptBlockNetDNSSlow = {
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
        try {
            $DnsCheck = [Net.DNS]::GetHostAddresses($FQDN)
        } catch { $DnsCheck = $null }
        if ($DnsCheck -ne $null) {
            $Blacklisted += [PSCustomObject] @{
                IP        = $ip
                FQDN      = $fqdn
                BlackList = $server
                IsListed  = $true
                Answer    = $DnsCheck.IPAddressToString -join ', '
                TTL       = ''
            }
        } else {
            $Blacklisted += [PSCustomObject] @{
                IP        = $IP
                FQDN      = $FQDN
                BlackList = $Server
                IsListed  = $false
                Answer    = $DnsCheck.IPAddress
                TTL       = ''
            }
        }
    }
    return $Blacklisted
}