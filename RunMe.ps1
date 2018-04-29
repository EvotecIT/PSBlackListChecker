Import-Module PSBlackListChecker.psm1 -Force

Search-BlackList -IP '89.25.253.18' -ReturnAll | Format-Table -AutoSize

Search-BlackList -IP '89.25.253.1' -ReturnAll -SortBy IsListed -SortDescending $true
Search-BlackList -IP '89.25.253.1', '89.25.253.2' -ReturnAll -SortBy Ip | Format-Table -AutoSize
Search-BlackList -IP '89.25.253.1', '89.25.253.2' -ReturnAll -SortBy BlackList | Format-Table -AutoSize