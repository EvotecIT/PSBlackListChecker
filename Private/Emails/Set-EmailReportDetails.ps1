function Set-EmailReportDetails {
    param(
        $FormattingOptions,
        $ReportOptions,
        $TimeToGenerate
    )
    $DateReport = get-date
    # HTML Report settings
    $Report = "<p style=`"background-color:white;font-family:$($FormattingOptions.FontFamily);font-size:$($FormattingOptions.FontSize)`">"
    $Report += "<strong>Report Time:</strong> $DateReport <br>"
    $Report += "<strong>Time to generate:</strong> $($TimeToGenerate.Hours) hours, $($TimeToGenerate.Minutes) minutes, $($TimeToGenerate.Seconds) seconds, $($TimeToGenerate.Milliseconds) milliseconds <br>"
    $Report += "<strong>Account Executing Report :</strong> $env:userdomain\$($env:username.toupper()) on $($env:ComputerName.toUpper()) <br>"
    $Report += '<strong>Checking for monitored IPs :</strong>'
    $Report += '<ul>'
    foreach ($ip in $ReportOptions.MonitoredIps.Values) {
        $Report += "<li>ip:</strong> $ip</li>"
    }
    $Report += '</ul>'
    $Report += '</p>'
    return $Report
}