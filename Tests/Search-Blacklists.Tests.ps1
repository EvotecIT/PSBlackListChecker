param (
    $TeamsID = $Env:TEAMSPESTERID,
    $SlackID = $Env:SLACKPESTERID
)
#Requires -Modules Pester
Import-Module $PSScriptRoot\..\PSBlackListChecker.psd1 -Force #-Verbose

$IP = '89.74.48.96'

Describe 'Search-Blacklists - Should test IP for blacklists' {
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
    It 'Given 1 IP - Workflow using [Resolve-DnsName] - Should return at least 2 listed blacklists' {
        $BlackList = Search-Blacklist -IP $IP -RunType WorkflowResolveDNS
        $BlackList.Count | Should -BeGreaterThan 1
        $BlackList.IsListed | Should -Contain $True
    }
    It 'Given 1 IP - Workflow using [Net.DNS] - Should return at least 2 listed blacklists' {
        $BlackList = Search-Blacklist -IP $IP -RunType WorkflowWithNetDNS
        $BlackList.Count | Should -BeGreaterThan 1
        $BlackList.IsListed | Should -Contain $True
    }
}