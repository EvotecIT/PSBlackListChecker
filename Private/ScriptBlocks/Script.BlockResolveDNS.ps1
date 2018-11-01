$Script:ScriptBlockResolveDNS = {
    param (
        [string] $Server,
        [string] $IP,
        [bool] $QuickTimeout,
        [bool] $Verbose
    )
    if ($Verbose) {
        $verbosepreference = 'continue'
    }
    $ReversedIP = ($IP -split '\.')[3..0] -join '.'
    $FQDN = "$ReversedIP.$Server"
    $DnsCheck = Resolve-DnsName -Name $fqdn -DnsOnly -ErrorAction 'SilentlyContinue' -NoHostsFile -QuickTimeout:$QuickTimeout # Impact of using -QuickTimeout unknown
    if ($DnsCheck -ne $null) {
        $ServerData = [PSCustomObject] @{
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
    return $ServerData
}