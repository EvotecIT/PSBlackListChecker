Clear-Host
Import-Module PSBlackListChecker.psm1 -Force
#Import-Module $PSScriptRoot\..\PSBlackListChecker.psm1 -Force

$RunTypes = 'NoWorkflowAndRunSpaceNetDNS', 'NoWorkflowAndRunSpaceResolveDNS', 'WorkflowResolveDNS', 'WorkflowWithNetDNS', 'RunSpaceWithResolveDNS', 'RunSpaceWithNetDNS'

foreach ($RunType in $RunTypes) {
    Write-Color '[', 'start', ']', ' Testing ', $RunType -Color White, Yellow, White, White, Yellow
    $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    Search-BlackList -IP '89.74.48.96' -RunType $RunType | Format-Table -AutoSize
    $StopWatch.Stop()
    Write-Color '[', 'end  ', ']', ' Elapsed ', $RunType, ' minutes: ', $StopWatch.Elapsed.Minutes, ' seconds: ', $StopWatch.Elapsed.Seconds, ' Milliseconds: ', $StopWatch.Elapsed.Milliseconds -Color White, Yellow, White, White, Yellow, White, Yellow, White, Green, White, Green, White, Green
}