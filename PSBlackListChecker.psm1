#requires -Modules DNSClient
#requites -Version 3.0

[string[]] $BlackLists = @(
    'b.barracudacentral.org'
    'spam.rbl.msrbl.net'
    'zen.spamhaus.org'
    'bl.deadbeef.com'
    'bl.emailbasura.org'
    'bl.spamcannibal.org'
    'bl.spamcop.net'
    'blackholes.five-ten-sg.com'
    'blacklist.woody.ch'
    'bogons.cymru.com'
    'cbl.abuseat.org'
    'cdl.anti-spam.org.cn'
    'combined.abuse.ch'
    'combined.rbl.msrbl.net'
    'db.wpbl.info'
    'dnsbl-1.uceprotect.net'
    'dnsbl-2.uceprotect.net'
    'dnsbl-3.uceprotect.net'
    # 'dnsbl.ahbl.org' # as per https://ahbl.org/ was terminated in 2015
    'dnsbl.cyberlogic.net'
    'dnsbl.inps.de'
    'dnsbl.njabl.org'
    'dnsbl.sorbs.net'
    'drone.abuse.ch'
    'drone.abuse.ch'
    'duinv.aupads.org'
    'dul.dnsbl.sorbs.net'
    'dul.ru'
    'dyna.spamrats.com'
    'dynip.rothen.com'
    'http.dnsbl.sorbs.net'
    'images.rbl.msrbl.net'
    'ips.backscatterer.org'
    'ix.dnsbl.manitu.net'
    'korea.services.net'
    'misc.dnsbl.sorbs.net'
    'noptr.spamrats.com'
    'ohps.dnsbl.net.au'
    'omrs.dnsbl.net.au'
    'orvedb.aupads.org'
    'osps.dnsbl.net.au'
    'osrs.dnsbl.net.au'
    'owfs.dnsbl.net.au'
    'owps.dnsbl.net.au'
    'pbl.spamhaus.org'
    'phishing.rbl.msrbl.net'
    'probes.dnsbl.net.au'
    'proxy.bl.gweep.ca'
    'proxy.block.transip.nl'
    'psbl.surriel.com'
    'rbl.interserver.net'
    'rdts.dnsbl.net.au'
    'relays.bl.gweep.ca'
    'relays.bl.kundenserver.de'
    'relays.nether.net'
    'residential.block.transip.nl'
    'ricn.dnsbl.net.au'
    'rmst.dnsbl.net.au'
    'sbl.spamhaus.org'
    'short.rbl.jp'
    'smtp.dnsbl.sorbs.net'
    'socks.dnsbl.sorbs.net'
    'spam.abuse.ch'
    'spam.dnsbl.sorbs.net'
    'spam.spamrats.com'
    'spamlist.or.kr'
    'spamrbl.imp.ch'
    't3direct.dnsbl.net.au'
    #'tor.ahbl.org' # as per https://ahbl.org/ was terminated in 2015
    'tor.dnsbl.sectoor.de'
    'torserver.tor.dnsbl.sectoor.de'
    'ubl.lashback.com'
    'ubl.unsubscore.com'
    'virbl.bit.nl'
    'virus.rbl.jp'
    'virus.rbl.msrbl.net'
    'web.dnsbl.sorbs.net'
    'wormrbl.imp.ch'
    'xbl.spamhaus.org'
    'zombie.dnsbl.sorbs.net'
)

function Search-BlackList {
    <#
      .SYNOPSIS
      Search-Blacklist searches if particular IP is blacklisted on DNSBL Blacklists.
      .DESCRIPTION

      .PARAMETER IPs

      .PARAMETER BlacklistServers

      .PARAMETER ReturnAll

      .PARAMETER SortBy

      .PARAMETER SortDescending

      .EXAMPLE
      Search-BlackList -IP '89.25.253.1' | Format-Table
      Search-BlackList -IP '89.25.253.1' -SortBy Blacklist | Format-Table
      Search-BlackList -IP '89.25.253.1','195.55.55.55' -SortBy Ip -ReturnAll | Format-Table

      .NOTES

    #>
    param
    (
        [string[]] $IPs,
        [string[]] $BlacklistServers = $BlackLists,
        [switch] $ReturnAll,
        [ValidateSet('IP', 'BlackList', 'IsListed', 'Answer', 'FQDN')]
        [string] $SortBy = 'IsListed',
        [switch] $SortDescending,
        [switch] $QuickTimeout
    )
    workflow Get-Blacklists {
        param (
            [string[]] $BlacklistServers,
            [string[]] $Ips,
            [bool] $QuickTimeout
        )
        $blacklistedOn = @()
        foreach -parallel ($server in $BlacklistServers) {
            #foreach ($server in $BlackLists) {
            foreach ($ip in $ips) {
                $reversedIP = ($IP -split '\.')[3..0] -join '.'
                $fqdn = "$reversedIP.$server"
                $DnsCheck = Resolve-DnsName -Name $fqdn -DnsOnly -ErrorAction 'SilentlyContinue' -NoHostsFile -QuickTimeout:$QuickTimeout # Impact of using -QuickTimeout unknown
                if ($DnsCheck -ne $null) {
                    $ServerData = @{
                        IP        = $ip
                        FQDN      = $fqdn
                        BlackList = $server
                        IsListed  = $true
                        Answer    = $DnsCheck.IPAddress -join ', '
                        TTL       = $DnsCheck.TTL
                    }
                } else {
                    $ServerData = @{
                        IP        = $ip
                        FQDN      = $fqdn
                        BlackList = $server
                        IsListed  = $false
                        Answer    = $DnsCheck.IPAddress
                        TTL       = ''
                    }
                }
                $WORKFLOW:blacklistedOn += $ServerData
            }
        }
        return $WORKFLOW:blacklistedOn
    }
    $Output = Get-Blacklists -BlacklistServers $BlacklistServers -Ips $IPs -QuickTimeout $QuickTimeout

    $table = $(foreach ($ht in $Output) {new-object PSObject -Property $ht}) | Select-Object IP, BlackList, IsListed, Answer, TTL, FQDN
    if ($SortDescending -eq $true) {
        $table = $table | Sort-Object $SortBy -Descending
    } else {
        $table = $table | Sort-Object $SortBy
    }
    if ($ReturnAll -eq $true) {
        return $table
    } else {
        return $table | Where-Object { $_.IsListed -eq $true }
    }
}

function Start-ReportBlackLists ($EmailParameters, $FormattingParameters, $ReportOptions) {

    $EmailBody = Set-EmailHead  -FormattingOptions $FormattingParameters
    $EmailBody += Set-EmailReportBrading -FormattingOptions $FormattingParameters

    $Ips = @()
    foreach ($ip in $ReportOptions.MonitoredIps.Values) {
        $Ips += $ip
    }
    $time = Measure-Command -Expression {
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
    if ($ReportOptions.EmailAlways -eq $true) {
        $SendMail = Send-Email -EmailParameters $EmailParameters -Body $EmailBody
    } else {
        if ($BlackListCheck.IsListed -contains $true) {
            $SendMail = Send-Email -EmailParameters $EmailParameters -Body $EmailBody
        }
    }
}

function Set-EmailHead($FormattingOptions) {
    $Head = '<style>' +
    "BODY{background-color:white;font-family:$($FormattingOptions.FontFamily);font-size:$($FormattingOptions.FontSize)}" +
    'TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse}' +
    "TH{border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color:`"#00297A`";font-color:white}" +
    'TD{border-width: 1px;padding-right: 2px;padding-left: 2px;padding-top: 0px;padding-bottom: 0px;border-style: solid;border-color: black;background-color:white}' +
    "H2{font-family:$($FormattingOptions.FontHeadingFamily);font-size:$($FormattingOptions.FontHeadingSize)}" +
    "P{font-family:$($FormattingOptions.FontFamily);font-size:$($FormattingOptions.FontSize)}" +
    "LI{font-family:$($FormattingOptions.FontFamily);font-size:$($FormattingOptions.FontSize)}" +
    '</style>'
    return $Head
}
function Set-EmailBody($TableData, $TableWelcomeMessage) {
    $body = "<p><i>$TableWelcomeMessage</i>"
    if ($($TableData | Measure-Object).Count -gt 0) {
        $body += $TableData | ConvertTo-Html -Fragment | Out-String
        $body = $body -replace ' Added', "<font color=`"green`"><b> Added</b></font>"
        $body = $body -replace ' Removed', "<font color=`"red`"><b> Removed</b></font>"
        $body = $body -replace ' Deleted', "<font color=`"red`"><b> Deleted</b></font>"
        $body = $body -replace ' Changed', "<font color=`"blue`"><b> Changed</b></font>"
        $body = $body -replace ' Change', "<font color=`"blue`"><b> Change</b></font>"
        $body = $body -replace ' Disabled', "<font color=`"red`"><b> Disabled</b></font>"
        $body = $body -replace ' Enabled', "<font color=`"green`"><b> Enabled</b></font>"
        $body = $body -replace ' Locked out', "<font color=`"red`"><b> Locked out</b></font>"
        $body = $body -replace ' Lockouts', "<font color=`"red`"><b> Lockouts</b></font>"
        $body = $body -replace ' Unlocked', "<font color=`"green`"><b> Unlocked</b></font>"
        $body = $body -replace ' Reset', "<font color=`"blue`"><b> Reset</b></font>"
        $body += '</p>'
    } else {
        $body += '<br><i>No changes happend during that period.</i></p>'
    }
    return $body
}
function Set-EmailReportBrading($FormattingOptions) {
    $Report = "<a style=`"text-decoration:none`" href=`"$($FormattingOptions.CompanyBranding.Link)`" class=`"clink logo-container`">" +
    "<img width=<fix> height=<fix> src=`"$($FormattingOptions.CompanyBranding.Logo)`" border=`"0`" class=`"company-logo`" alt=`"company-logo`">" +
    '</a>'
    if ($FormattingOptions.CompanyBranding.Width -ne '') {
        $report = $report -replace 'width=<fix>', "width=$($FormattingOptions.CompanyBranding.Width)"
    } else {
        $report = $report -replace 'width=<fix>', ''
    }
    if ($FormattingOptions.CompanyBranding.Height -ne '') {
        $report = $report -replace 'height=<fix>', "height=$($FormattingOptions.CompanyBranding.Height)"
    } else {
        $report = $report -replace 'height=<fix>', ''
    }
    return $Report
}
function Set-EmailReportDetails($FormattingOptions, $ReportOptions, $TimeToGenerate) {
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

function Send-Email ([hashtable] $EmailParameters, [string] $Body = "", $Attachment = $null, [string] $Subject = "", $To = "") {
    #  Preparing the Email properties
    $SmtpClient = New-Object -TypeName system.net.mail.smtpClient
    $SmtpClient.host = $EmailParameters.EmailServer

    # Adding parameters to login to server
    $SmtpClient.Port = $EmailParameters.EmailServerPort
    if ($EmailParameters.EmailServerLogin -ne "") {
        $SmtpClient.Credentials = New-Object System.Net.NetworkCredential($EmailParameters.EmailServerLogin, $EmailParameters.EmailServerPassword)
    }
    $SmtpClient.EnableSsl = $EmailParameters.EmailServerEnableSSL
    $MailMessage = New-Object -TypeName system.net.mail.mailmessage
    $MailMessage.From = $EmailParameters.EmailFrom
    if ($To -ne "") {
        foreach ($T in $To) { $MailMessage.To.add($($T)) }
    } else {
        if ($EmailParameters.Emailto -ne "") {
            foreach ($To in $EmailParameters.Emailto) { $MailMessage.To.add($($To)) }
        }
    }
    if ($EmailParameters.EmailCC -ne "") {
        foreach ($CC in $EmailParameters.EmailCC) { $MailMessage.CC.add($($CC)) }
    }
    if ($EmailParameters.EmailBCC -ne "") {
        foreach ($BCC in $EmailParameters.EmailBCC) { $MailMessage.BCC.add($($BCC)) }
    }
    $Exists = Test-Key $EmailParameters "EmailParameters" "EmailReplyTo" -DisplayProgress $false
    if ($Exists -eq $true) {
        if ($EmailParameters.EmailReplyTo -ne "") {
            $MailMessage.ReplyTo = $EmailParameters.EmailReplyTo
        }
    }
    $MailMessage.IsBodyHtml = 1
    if ($Subject -eq "") {
        $MailMessage.Subject = $EmailParameters.EmailSubject
    } else {
        $MailMessage.Subject = $Subject
    }
    $MailMessage.Body = $Body
    $MailMessage.Priority = [System.Net.Mail.MailPriority]::$($EmailParameters.EmailPriority)

    #  Encoding
    $MailMessage.BodyEncoding = [System.Text.Encoding]::$($EmailParameters.EmailEncoding)
    $MailMessage.SubjectEncoding = [System.Text.Encoding]::$($EmailParameters.EmailEncoding)

    #  Attaching file (s)
    if ($Attachment -ne $null) {
        foreach ($Attach in $Attachment) {
            if (Test-Path $Attach) {
                $File = new-object Net.Mail.Attachment($Attach)
                $MailMessage.Attachments.Add($File)
            }
        }
    }
    #  Sending the Email
    try {
        $SmtpClient.Send($MailMessage)
        $MailMessage.Dispose();
        return @{
            Status = $True
            Error  = ""
        }
    } catch {
        $MailMessage.Dispose();
        return @{
            Status = $False
            Error  = $($_.Exception.Message)
        }
    }

}
function Test-Key ($ConfigurationTable, $ConfigurationSection = "", $ConfigurationKey, $DisplayProgress = $false) {
    if ($ConfigurationTable -eq $null) { return $false }
    try {
        $value = $ConfigurationTable.ContainsKey($ConfigurationKey)
    } catch {
        $value = $false
    }
    if ($value -eq $true) {
        if ($DisplayProgress -eq $true) {
            Write-Color @script:WriteParameters -Text "[i] ", "Parameter in configuration of ", "$ConfigurationSection.$ConfigurationKey", " exists." -Color White, White, Green, White
        }
        return $true
    } else {
        if ($DisplayProgress -eq $true) {
            Write-Color @script:WriteParameters -Text "[i] ", "Parameter in configuration of ", "$ConfigurationSection.$ConfigurationKey", " doesn't exist." -Color White, White, Red, White
        }
        return $false
    }
}

Export-ModuleMember -function 'Search-BlackList', 'Start-ReportBlackLists'