#Import-Module PSBlackListChecker.psm1 #-Force
Import-Module $PSScriptRoot\..\PSBlackListChecker.psm1 -Force


$StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
Search-BlackList -IP '89.74.48.96' | Format-Table -AutoSize
$StopWatch.Stop()
$StopWatch.Elapsed

$StopWatch1 = [System.Diagnostics.Stopwatch]::StartNew()
Search-BlackList1 -IP '89.74.48.96' -MaxRunspaces 12 | Format-Table -AutoSize
$StopWatch1.Stop()
$StopWatch1.Elapsed


$StopWatch2 = [System.Diagnostics.Stopwatch]::StartNew()
Search-BlackList2 -IP '89.74.48.96' -MaxRunspaces 12 | Format-Table -AutoSize
$StopWatch2.Stop()
$StopWatch2.Elapsed

$StopWatch3 = [System.Diagnostics.Stopwatch]::StartNew()
Search-BlackList3 -IP '89.74.48.96' | Format-Table -AutoSize
$StopWatch3.Stop()
$StopWatch3.Elapsed





























#Search-BlackList -IP '89.25.253.1' -ReturnAll -SortBy IsListed -SortDescending $true
#Search-BlackList -IP '89.25.253.1', '89.25.253.2' -ReturnAll -SortBy Ip | Format-Table -AutoSize
#Search-BlackList -IP '89.25.253.1', '89.25.253.2' -ReturnAll -SortBy BlackList | Format-Table -AutoSize

<#
$IP = '89.74.48.96'
$Server = 'b.barracudacentral.org'

$reversedIP = ($IP -split '\.')[3..0] -join '.'
$fqdn = "$reversedIP.$server"

$DnsCheck = [Net.DNS]::GetHostAddresses($fqdn)
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

$ServerData
#>