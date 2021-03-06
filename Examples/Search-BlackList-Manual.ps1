Import-Module ..\PSBlackListChecker -Force

$IP = '89.74.48.96'
$IP1 = '89.74.48.97'
$MultipleIP = $IP, $IP1

Write-Color "Test 1" -Color Red
Search-BlackList -IP $IP | Format-Table -AutoSize
Write-Color "Test 2" -Color Red
Search-BlackList -IP $IP -ReturnAll | Format-Table -AutoSize