function Search-BlackList {
    [cmdletbinding()]
    <#
      .SYNOPSIS
      Search-Blacklist searches if particular IP is blacklisted on DNSBL Blacklists.
      .DESCRIPTION

      .PARAMETER IPs

      .PARAMETER BlacklistServers

      .PARAMETER ReturnAll

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
        [string[]] $IPs,
        [string[]] $BlacklistServers = $BlackLists,
        [switch] $ReturnAll,
        [ValidateSet('NoWorkflowAndRunSpaceNetDNS', 'NoWorkflowAndRunSpaceResolveDNS', 'WorkflowResolveDNS', 'WorkflowWithNetDNS', 'RunSpaceWithResolveDNS', 'RunSpaceWithNetDNS')][string]$RunType = 'RunSpaceWithResolveDNS',
        [ValidateSet('IP', 'BlackList', 'IsListed', 'Answer', 'FQDN')][string] $SortBy = 'IsListed',
        [switch] $SortDescending,
        [switch] $QuickTimeout,
        [int] $MaxRunspaces = [int]$env:NUMBER_OF_PROCESSORS + 1
    )
    if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) { $Verbose = $true } else { $Verbose = $false }

    If ($RunType -eq 'NoWorkflowAndRunSpaceNetDNS') {
        $Output = Invoke-Command -ScriptBlock $ScriptBlockNetDNSSlow -ArgumentList $BlacklistServers, $IPs, $QuickTimeout, $Verbose
    } elseif ($RunType -eq 'NoWorkflowAndRunSpaceResolveDNS') {
        $Output = Invoke-Command -ScriptBlock $ScriptBlockResolveDNSSlow -ArgumentList $BlacklistServers, $IPs, $QuickTimeout, $Verbose
    } elseif ($RunType -eq 'WorkflowResolveDNS') {
        $Output = Get-BlacklistsResolveDNS -BlacklistServers $BlacklistServers -Ips $IPs -QuickTimeout $QuickTimeout
    } elseif ($RunType -eq 'WorkflowWithNetDNS') {
        $Output = Get-BlacklistsNetDNS -BlacklistServers $BlacklistServers -Ips $IPs -QuickTimeout $QuickTimeout
    } elseif ($RunType -eq 'RunSpaceWithResolveDNS') {
        ### Define Runspace START
        $runspaces = @()
        $pool = New-Runspace -MaxRunspaces $maxRunspaces -Verbose:$Verbose
        ### Define Runspace END

        foreach ($server in $BlacklistServers) {
            foreach ($ip in $ips) {
                $Parameters = [ordered] @{
                    Server       = $Server
                    IP           = $IP
                    QuickTimeout = $QuickTimeout
                    Verbose      = $Verbose
                }
                $runspaces += Start-Runspace -ScriptBlock $ScriptBlockResolveDNS -Parameters $Parameters -RunspacePool $pool -Verbose:$Verbose
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
            foreach ($ip in $ips) {
                $Parameters = [ordered] @{
                    Server       = $Server
                    IP           = $IP
                    QuickTimeout = $QuickTimeout
                    Verbose      = $Verbose
                }
                $runspaces += Start-Runspace -ScriptBlock $ScriptBlockNetDNS -Parameters $Parameters -RunspacePool $pool -Verbose:$Verbose
            }
        }
        #    $Output = Get-Blacklists -BlacklistServers $BlacklistServers -Ips $IPs -QuickTimeout $QuickTimeout

        ### End Runspaces START
        $Output = Stop-Runspace -Runspaces $runspaces -FunctionName 'Search-BlackList' -RunspacePool $pool -Verbose:$Verbose
        ### End Runspaces END
    }

    $table = $(foreach ($ht in $Output) {new-object PSObject -Property $ht}) | Select-Object IP, BlackList, IsListed, Answer, TTL, FQDN
    if ($SortDescending -eq $true) {
        $table = $table | Sort-Object $SortBy -Descending
    } else {
        $table = $table | Sort-Object $SortBy
    }
    if ($ReturnAll -eq $true) {
        return $table
    } else {
        return $table | Where-Object { $_.IsListed -eq $true }
    }
}