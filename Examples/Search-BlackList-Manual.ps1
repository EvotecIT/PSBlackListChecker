Import-Module ..\PSSharedGoods\PSSharedGoods.psd1 -Force
Import-Module ..\PSBlackListChecker -Force

$IP = '89.74.48.96'
$IP1 = '89.74.48.97'
$MultipleIP = $IP, $IP1

Write-Color "Test 1" -Color Red
Search-BlackList -IP $IP  | Format-Table -AutoSize
Write-Color "Test 2" -Color Red
Search-BlackList -IP $IP -ReturnAll | Format-Table -AutoSize

#return
## Other ideas below

Write-Color "Test 3" -Color Red
Search-BlackList -IP $IP -RunType RunSpaceWithResolveDNS | Format-Table -AutoSize
Write-Color "Test 4" -Color Red
Search-BlackList -IP $IP -RunType RunSpaceWithNetDNS | Format-Table -AutoSize
Write-Color "Test 5" -Color Red
Search-Blacklist -IP $IP -RunType NoWorkflowAndRunSpaceNetDNS | Format-Table
Write-Color "Test 6" -Color Red
Search-BlackList -IP $IP -ReturnAll | Format-Table -AutoSize
Write-Color "Test 7" -Color Red
Search-BlackList -IP $IP -ReturnAll -SortBy IsListed -SortDescending | Format-Table -AutoSize
Write-Color "Test 8" -Color Red
Search-BlackList -IP $MultipleIP -ReturnAll -SortBy Ip | Format-Table -AutoSize
Write-Color "Test 9" -Color Red
Search-BlackList -IP $MultipleIP -ReturnAll -SortBy BlackList | Format-Table -AutoSize
