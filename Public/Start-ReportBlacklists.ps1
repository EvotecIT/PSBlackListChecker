function Start-ReportBlackLists {
    [cmdletbinding()]
    param(
        $EmailParameters,
        $FormattingParameters,
        $ReportOptions
    )
    $EmailBody = Set-EmailHead -FormattingOptions $FormattingParameters
    $EmailBody += Set-EmailReportBranding -FormattingOptions $FormattingParameters

    $Ips = @()
    foreach ($ip in $ReportOptions.MonitoredIps.Values) {
        $Ips += $ip
    }
    $Time = Measure-Command -Expression {
        if ($ReportOptions.EmailAllResults) {
            $BlackListCheck = Search-BlackList -IP $Ips -SortBy $ReportOptions.SortBy -SortDescending:$ReportOptions.SortDescending -ReturnAll
        } else {
            $BlackListCheck = Search-BlackList -IP $Ips -SortBy $ReportOptions.SortBy -SortDescending:$ReportOptions.SortDescending
        }
    }
    $EmailBody += Set-EmailReportDetails -FormattingOptions $FormattingParameters -ReportOptions $ReportOptions -TimeToGenerate $Time
    $EmailBody += Set-EmailBody -TableData $BlackListCheck -TableWelcomeMessage 'Following blacklisted servers'

    if ($BlackListCheck.IsListed -contains $true) {
        $EmailParameters.EmailPriority = $ReportOptions.EmailPriorityWhenBlacklisted
    } else {
        $EmailParameters.EmailPriority = $ReportOptions.EmailPriorityStandard
    }
    # Sending email - finalizing package
    if ($ReportOptions.EmailAlways -eq $true -or $BlackListCheck.IsListed -contains $true) {
        if ($FormattingParameters.CompanyBranding.Inline) {
            $SendMail = Send-Email -EmailParameters $EmailParameters -Body $EmailBody -InlineAttachments @{logo = $FormattingParameters.CompanyBranding.Logo} -Verbose
        } else {
            $SendMail = Send-Email -EmailParameters $EmailParameters -Body $EmailBody
        }
    }
}