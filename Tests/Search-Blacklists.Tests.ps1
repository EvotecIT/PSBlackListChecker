param (
    $TeamsID = $Env:TEAMSPESTERID,
    $SlackID = $Env:SLACKPESTERID,
    $DiscordID = $Env:DISCORDURL
)

Describe 'Search-Blacklists - Should test IP for blacklists' {
    $IP = '89.74.48.96'

    It 'Given 1 IP - Standard Way - Should return at least 2 blackslists' {
        $BlackList = Search-BlackList -IP $IP
        $BlackList.Count | Should -BeGreaterThan 1
        $BlackList.Count | Should -BeLessThan 10
        $BlackList.IsListed | Should -Contain $True
    }
    It 'Given 1 IP - Standard way with -ReturnAll switch - should return 78 lists' {
        $BlackList = Search-BlackList -IP $IP -ReturnAll
        $BlackList.Count | Should -Be 77
        $BlackList.IsListed | Should -Contain $True
    }
    It 'Given 1 IP - No Workflow or RunSpaces using [Net.DNS]- Should return at least 2 listed blacklists' {
        $BlackList = Search-Blacklist -IP $IP -RunType NoWorkflowAndRunSpaceNetDNS
        $BlackList.Count | Should -BeGreaterThan 1
        $BlackList.IsListed | Should -Contain $True
    }
    It 'Given 1 IP - No Workflow or RunSpaces using [Resolve-DnsName] - Should return at least 2 listed blacklists' {
        $BlackList = Search-Blacklist -IP $IP -RunType NoWorkflowAndRunSpaceResolveDNS
        $BlackList.Count | Should -BeGreaterThan 1
        $BlackList.IsListed | Should -Contain $True
    }
    It 'Given 1 IP - RunSpaces using [Net.DNS] - Should return at least 2 listed blacklists' {
        $BlackList = Search-Blacklist -IP $IP -RunType RunSpaceWithNetDNS
        $BlackList.Count | Should -BeGreaterThan 1
        $BlackList.IsListed | Should -Contain $True
    }
    It 'Given 1 IP - RunSpaces using [Resolve-DnsName] - Should return at least 2 listed blacklists' {
        $BlackList = Search-Blacklist -IP $IP -RunType RunSpaceWithResolveDNS
        $BlackList.Count | Should -BeGreaterThan 1
        $BlackList.IsListed | Should -Contain $True
    }
    It 'Given 1 IP - RunSpaces using [Resolve-DnsName] - Should return at least 2 listed blacklists, Sorted by IsListed' {
        $BlackList = Search-Blacklist -IP $IP -SortBy IsListed
        $BlackList.Count | Should -BeGreaterThan 1
        $BlackList[-1].IsListed | Should -Contain $True
    }
    It 'Given 1 IP - RunSpaces using [Resolve-DnsName] - Should return at least 2 listed blacklists, Sorted by IsListed, Descending' {
        $BlackList = Search-Blacklist -IP $IP -SortBy IsListed -SortDescending
        $BlackList.Count | Should -BeGreaterThan 1
        $BlackList[0].IsListed | Should -Contain $True
    }
}

Describe 'Search-Blacklists - Should test multiple IPs for blacklists' {
    $IP = '89.74.48.96','89.74.48.97','89.74.48.98'

    It 'Given 3 IP - Standard Way - Should return at least 3 blackslists' {
        $BlackList = Search-BlackList -IP $IP -DNSServer '1.1.1.1', '8.8.8.8'
        $BlackList.IP | Should -Contain '89.74.48.96'
        $BlackList.IP | Should -Contain '89.74.48.97'
        $BlackList.IP | Should -Contain '89.74.48.98'
        $BlackList.Count | Should -BeGreaterThan 3
        $BlackList.Count | Should -BeLessThan 20
        $BlackList.IsListed | Should -Contain $True
    }
    It 'Given 3 IP - Standard way with -ReturnAll switch - should return 234 lists' {
        $BlackList = Search-BlackList -IP $IP -ReturnAll -DNSServer '1.1.1.1', '8.8.8.8'
        $BlackList.Count | Should -Be 231
        $BlackList.IsListed | Should -Contain $True
    }
    It 'Given 3 IP - No Workflow or RunSpaces using [Net.DNS]- Should return at least 2 listed blacklists' {
        $BlackList = Search-Blacklist -IP $IP -RunType NoWorkflowAndRunSpaceNetDNS
        $BlackList.Count | Should -BeGreaterOrEqual 6
        $BlackList.IsListed | Should -Contain $True
    }
    It 'Given 3 IP - No Workflow or RunSpaces using [Resolve-DnsName] - Should return at least 2 listed blacklists' {
        $BlackList = Search-Blacklist -IP $IP -RunType NoWorkflowAndRunSpaceResolveDNS
        $BlackList.Count | Should -BeGreaterOrEqual 6
        $BlackList.IsListed | Should -Contain $True
    }
    It 'Given 3 IP - RunSpaces using [Net.DNS] - Should return at least 2 listed blacklists' {
        $BlackList = Search-Blacklist -IP $IP -RunType RunSpaceWithNetDNS
        $BlackList.Count | Should -BeGreaterOrEqual 6
        $BlackList.IsListed | Should -Contain $True
    }
    It 'Given 3 IP - RunSpaces using [Resolve-DnsName] - Should return at least 2 listed blacklists' {
        $BlackList = Search-Blacklist -IP $IP -RunType RunSpaceWithResolveDNS -DNSServer '1.1.1.1', '8.8.8.8'
        $BlackList.Count | Should -BeGreaterOrEqual 6
        $BlackList.IsListed | Should -Contain $True
    }
}