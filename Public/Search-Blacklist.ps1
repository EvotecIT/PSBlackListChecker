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
        [ValidateSet('NoWorkflowAndRunSpaceNetDNS', 'NoWorkflowAndRunSpaceResolveDNS', 'RunSpaceWithResolveDNS', 'RunSpaceWithNetDNS', 'WorkflowResolveDNS', 'WorkflowWithNetDNS')][string]$RunType = 'RunSpaceWithResolveDNS',
        [ValidateSet('IP', 'BlackList', 'IsListed', 'Answer', 'FQDN')][string] $SortBy = 'IsListed',
        [switch] $SortDescending,
        [switch] $QuickTimeout,
        [int] $MaxRunspaces = [int]$env:NUMBER_OF_PROCESSORS + 1,
        [switch] $ExtendedOutput
    )
    if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) { $Verbose = $true } else { $Verbose = $false }

    # will remove this after a while
    if ($RunType -eq 'WorkflowResolveDNS') {
        Write-Warning 'Worflows are not supported anymore due to PowerShell 6 complaining. Please use other modes.'
        Exit
    } elseif ($RunType -eq 'WorkflowWithNetDNS') {
        Write-Warning 'Worflows are not supported anymore due to PowerShell 6 complaining. Please use other modes.'
        Exit
    }

    if ($PSVersionTable.Platform -eq 'Unix') {
        if ($RunType -eq 'RunSpaceWithResolveDNS') {
            $RunType = 'RunSpaceWithNetDNS'
            Write-Warning 'Search-BlackList - changing RunType to RunSpaceWithNetDNS since Resolve-DNSName is not available on Linux/MacOS'
        } elseif ($RunType -eq 'NoWorkflowAndRunSpaceResolveDNS') {
            $RunType = 'NoWorkflowAndRunSpaceNetDNS'
            Write-Warning 'Search-BlackList - changing RunType to RunSpaceWithNetDNS since Resolve-DNSName is not available on Linux/MacOS'
        }
    }


    If ($RunType -eq 'NoWorkflowAndRunSpaceNetDNS') {
        $Table = Invoke-Command -ScriptBlock $Script:ScriptBlockNetDNSSlow -ArgumentList $BlacklistServers, $IPs, $QuickTimeout, $Verbose
    } elseif ($RunType -eq 'NoWorkflowAndRunSpaceResolveDNS') {
        $Table = Invoke-Command -ScriptBlock $Script:ScriptBlockResolveDNSSlow -ArgumentList $BlacklistServers, $IPs, $QuickTimeout, $Verbose
    } elseif ($RunType -eq 'RunSpaceWithResolveDNS') {
        ### Define Runspace START
        $pool = New-Runspace -MaxRunspaces $maxRunspaces -Verbose:$Verbose
        ### Define Runspace END
        $runspaces = foreach ($Server in $BlacklistServers) {
            foreach ($IP in $IPs) {
                $Parameters = @{
                    Server       = $Server
                    IP           = $IP
                    QuickTimeout = $QuickTimeout
                    Verbose      = $Verbose
                }
                Start-Runspace -ScriptBlock $Script:ScriptBlockResolveDNS -Parameters $Parameters -RunspacePool $pool -Verbose:$Verbose
            }
        }
        ### End Runspaces START
        $Output = Stop-Runspace -Runspaces $runspaces -FunctionName 'Search-BlackList' -RunspacePool $pool -Verbose:$Verbose -ErrorAction Continue -ErrorVariable MyErrors -ExtendedOutput:$ExtendedOutput
        if ($ExtendedOutput) {
            $Output # returns hashtable of Errors and Output
            Exit
        } else {
            $Table = $Output
        }
        ### End Runspaces END

    } elseif ($RunType -eq 'RunSpaceWithNetDNS') {
        ### Define Runspace START
        $pool = New-Runspace -MaxRunspaces $maxRunspaces -Verbose:$Verbose
        ### Define Runspace END
        $runspaces = foreach ($server in $BlacklistServers) {
            foreach ($ip in $IPs) {
                $Parameters = @{
                    Server       = $Server
                    IP           = $IP
                    QuickTimeout = $QuickTimeout
                    Verbose      = $Verbose
                }
                Start-Runspace -ScriptBlock $Script:ScriptBlockNetDNS -Parameters $Parameters -RunspacePool $pool -Verbose:$Verbose
            }
        }
        ### End Runspaces START
        $Output = Stop-Runspace -Runspaces $runspaces -FunctionName 'Search-BlackList' -RunspacePool $pool -Verbose:$Verbose -ExtendedOutput:$ExtendedOutput
        if ($ExtendedOutput) {
            $Output # returns hashtable of Errors and Output
            Exit
        } else {
            $Table = $Output
        }
        ### End Runspaces END
    }
    if ($SortDescending -eq $true) {
        $Table = $Table | Sort-Object $SortBy -Descending
    } else {
        $Table = $Table | Sort-Object $SortBy
    }
    if ($ReturnAll -eq $true) {
        return $Table | Select-Object IP, FQDN, BlackList, IsListed, Answer, TTL
    } else {
        return $Table | Where-Object { $_.IsListed -eq $true } | Select-Object IP, FQDN, BlackList, IsListed, Answer, TTL
    }
}