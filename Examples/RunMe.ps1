Import-Module PSBlackListChecker.psm1 -Force

Search-Blacklist -IP '89.74.48.96' -RunType NoWorkflowAndRunSpaceNetDNS -Verbose

return

Search-BlackList -IP '89.74.48.96' -ReturnAll | Format-Table -AutoSize

Search-BlackList -IP '89.74.48.96' -ReturnAll -SortBy IsListed -SortDescending $true
Search-BlackList -IP '89.74.48.96', '89.74.48.97' -ReturnAll -SortBy Ip | Format-Table -AutoSize
Search-BlackList -IP '89.74.48.96', '89.74.48.97' -ReturnAll -SortBy BlackList | Format-Table -AutoSize