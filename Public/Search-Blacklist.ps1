function Search-BlackList {
    [cmdletbinding()]
    <#
      .SYNOPSIS
      Search-Blacklist searches if particular IP is blacklisted on DNSBL Blacklists.
      .DESCRIPTION

      .PARAMETER IPs

      .PARAMETER BlacklistServers

      .PARAMETER ReturnAll

      .PARAMETER RunType

      .PARAMETER SortBy

      .PARAMETER SortDescending

      .EXAMPLE
      Search-BlackList -IP '89.25.253.1' | Format-Table
      Search-BlackList -IP '89.25.253.1' -SortBy Blacklist | Format-Table
      Search-BlackList -IP '89.25.253.1','195.55.55.55' -SortBy Ip -ReturnAll | Format-Table

      .NOTES

    #>
    param
    (
        [alias('IP')][string[]] $IPs,
        [string[]] $BlacklistServers = $Script:BlackLists,
        [switch] $ReturnAll,
        [ValidateSet('NoWorkflowAndRunSpaceNetDNS', 'NoWorkflowAndRunSpaceResolveDNS', 'WorkflowResolveDNS', 'WorkflowWithNetDNS', 'RunSpaceWithResolveDNS', 'RunSpaceWithNetDNS')][string]$RunType = 'RunSpaceWithResolveDNS',
        [ValidateSet('IP', 'BlackList', 'IsListed', 'Answer', 'FQDN')][string] $SortBy = 'IsListed',
        [switch] $SortDescending,
        [switch] $QuickTimeout,
        [int] $MaxRunspaces = [int]$env:NUMBER_OF_PROCESSORS + 1
    )
    if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) { $Verbose = $true } else { $Verbose = $false }

    If ($RunType -eq 'NoWorkflowAndRunSpaceNetDNS') {
        $Output = Invoke-Command -ScriptBlock $Script:ScriptBlockNetDNSSlow -ArgumentList $BlacklistServers, $IPs, $QuickTimeout, $Verbose
    } elseif ($RunType -eq 'NoWorkflowAndRunSpaceResolveDNS') {
        $Output = Invoke-Command -ScriptBlock $Script:ScriptBlockResolveDNSSlow -ArgumentList $BlacklistServers, $IPs, $QuickTimeout, $Verbose
    } elseif ($RunType -eq 'WorkflowResolveDNS') {
        $Output = Get-BlacklistsResolveDNS -BlacklistServers $BlacklistServers -Ips $IPs -QuickTimeout $QuickTimeout
    } elseif ($RunType -eq 'WorkflowWithNetDNS') {
        $Output = Get-BlacklistsNetDNS -BlacklistServers $BlacklistServers -Ips $IPs -QuickTimeout $QuickTimeout
    } elseif ($RunType -eq 'RunSpaceWithResolveDNS') {
        ### Define Runspace START
        $runspaces = @()
        $pool = New-Runspace -MaxRunspaces $maxRunspaces -Verbose:$Verbose
        ### Define Runspace END

        foreach ($Server in $BlacklistServers) {
            foreach ($IP in $IPs) {
                $Parameters = @{
                    Server       = $Server
                    IP           = $IP
                    QuickTimeout = $QuickTimeout
                    Verbose      = $Verbose
                }
                $runspaces += Start-Runspace -ScriptBlock $Script:ScriptBlockResolveDNS -Parameters $Parameters -RunspacePool $pool -Verbose:$Verbose
            }
        }
        ### End Runspaces START
        $Output = Stop-Runspace -Runspaces $runspaces -FunctionName 'Search-BlackList' -RunspacePool $pool -Verbose:$Verbose
        ### End Runspaces END

    } elseif ($RunType -eq 'RunSpaceWithNetDNS') {
        ### Define Runspace START
        $runspaces = @()
        $pool = New-Runspace -MaxRunspaces $maxRunspaces -Verbose:$Verbose
        ### Define Runspace END

        foreach ($server in $BlacklistServers) {
            foreach ($ip in $IPs) {
                $Parameters = @{
                    Server       = $Server
                    IP           = $IP
                    QuickTimeout = $QuickTimeout
                    Verbose      = $Verbose
                }
                $runspaces += Start-Runspace -ScriptBlock $Script:ScriptBlockNetDNS -Parameters $Parameters -RunspacePool $pool -Verbose:$Verbose
            }
        }
        ### End Runspaces START
        $Output = Stop-Runspace -Runspaces $runspaces -FunctionName 'Search-BlackList' -RunspacePool $pool -Verbose:$Verbose
        ### End Runspaces END
    }
    $Table = $Output | Select-Object IP, FQDN, BlackList, IsListed, Answer, TTL

    if ($SortDescending -eq $true) {
        $Table = $Table | Sort-Object $SortBy -Descending
    } else {
        $Table = $Table | Sort-Object $SortBy
    }
    if ($ReturnAll -eq $true) {
        return $Table
    } else {
        return $Table | Where-Object { $_.IsListed -eq $true }
    }
}