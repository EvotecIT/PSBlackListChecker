function Search-BlackList {
    <#
    .SYNOPSIS
    Search-Blacklist searches if particular IP is blacklisted on DNSBL Blacklists.

    .DESCRIPTION
    Long description

    .PARAMETER IPs
    Parameter description

    .PARAMETER BlacklistServers
    Parameter description

    .PARAMETER ReturnAll
    Parameter description

    .PARAMETER RunType
    Parameter description

    .PARAMETER SortBy
    Parameter description

    .PARAMETER SortDescending
    Parameter description

    .PARAMETER QuickTimeout
    Parameter description

    .PARAMETER MaxRunspaces
    Parameter description

    .PARAMETER ExtendedOutput
    Parameter description

    .EXAMPLE
    Search-BlackList -IP '89.25.253.1' | Format-Table

    .EXAMPLE
    Search-BlackList -IP '89.25.253.1' -SortBy Blacklist | Format-Table

    .EXAMPLE
    Search-BlackList -IP '89.25.253.1','195.55.55.55' -SortBy Ip -ReturnAll | Format-Table

    .NOTES
    General notes
    #>

    [cmdletbinding()]
    param
    (
        [alias('IP')][string[]] $IPs,
        [string[]] $BlacklistServers = $Script:BlackLists,
        [switch] $ReturnAll,
        [ValidateSet('NoWorkflowAndRunSpaceNetDNS', 'NoWorkflowAndRunSpaceResolveDNS', 'RunSpaceWithResolveDNS', 'RunSpaceWithNetDNS', 'WorkflowResolveDNS', 'WorkflowWithNetDNS')]
        [string]$RunType,
        [ValidateSet('IP', 'BlackList', 'IsListed', 'Answer', 'FQDN')][string] $SortBy = 'IsListed',
        [switch] $SortDescending,
        [switch] $QuickTimeout,
        [int] $MaxRunspaces = 10,
        [string[]] $DNSServer = '',
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

    # no parameter given (and it's expected)
    if ($RunType -eq '') {
        $RunType = 'RunSpaceWithNetDNS'
        <#
        if ($PSVersionTable.Platform -eq 'Unix') {
            $RunType = 'RunSpaceWithNetDNS'
        } else {
            $RunType = 'RunSpaceWithResolveDNS'
        }
        #>
    }

    # checks whether Runspaces are not set for use on Unix (usually forced by user)
    if ($PSVersionTable.Platform -eq 'Unix') {
        if ($RunType -eq 'RunSpaceWithResolveDNS') {
            $RunType = 'RunSpaceWithNetDNS'
            Write-Warning 'Search-BlackList - changing RunType to RunSpaceWithNetDNS since Resolve-DNSName is not available on Linux/MacOS'
        } elseif ($RunType -eq 'NoWorkflowAndRunSpaceResolveDNS') {
            $RunType = 'NoWorkflowAndRunSpaceNetDNS'
            Write-Warning 'Search-BlackList - changing RunType to RunSpaceWithNetDNS since Resolve-DNSName is not available on Linux/MacOS'
        }
    }

    if ($DNSServer -ne '' -and $RunType -like 'NetDNS') {
        Write-Warning 'Search-BlackList - Setting DNSServer is not supported for Net.DNS. Resetting to default values.'
        $DNSServer = ''
    }

    Write-Verbose "Search-Blacklist - Runtype: $RunType ReturnAll: $ReturnAll, SortBy: $SortBy MaxRunspaces: $MaxRunspaces SortDescending: $SortDescending"

    If ($RunType -eq 'NoWorkflowAndRunSpaceNetDNS') {
        $Table = Invoke-Command -ScriptBlock $Script:ScriptBlockNetDNSSlow -ArgumentList $BlacklistServers, $IPs, $QuickTimeout, $Verbose
    } elseif ($RunType -eq 'NoWorkflowAndRunSpaceResolveDNS') {
        $Table = Invoke-Command -ScriptBlock $Script:ScriptBlockResolveDNSSlow -ArgumentList $BlacklistServers, $IPs, $QuickTimeout, $Verbose, $DNSServer
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
                    DNSServer    = $DNSServer
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
                    #DNSServer    = $DNSServer
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