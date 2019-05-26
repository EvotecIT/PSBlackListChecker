function Set-EmailReportDetails {
    param(
        $FormattingOptions,
        $ReportOptions,
        $TimeToGenerate
    )
    $DateReport = get-date
    # HTML Report settings
    $Report = @(
        "<p style=`"background-color:white;font-family:$($FormattingOptions.FontFamily);font-size:$($FormattingOptions.FontSize)`">"
        "<strong>Report Time:</strong> $DateReport <br>"
        "<strong>Time to generate:</strong> $($TimeToGenerate.Hours) hours, $($TimeToGenerate.Minutes) minutes, $($TimeToGenerate.Seconds) seconds, $($TimeToGenerate.Milliseconds) milliseconds <br>"

        if ($PSVersionTable.Platform -ne 'Unix') {
            "<strong>Account Executing Report :</strong> $env:userdomain\$($env:username.toupper()) on $($env:ComputerName.toUpper()) <br>"
        } else {
            # needs filling in.
        }
        '<strong>Checking for monitored IPs :</strong>'
        '<ul>'
        foreach ($ip in $ReportOptions.MonitoredIps.Values) {
            "<li>ip:</strong> $ip</li>"
        }
        '</ul>'
        '</p>'
    )
    return $Report
}