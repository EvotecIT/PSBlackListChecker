function Start-ReportBlackLists {
    [cmdletbinding()]
    param(
        $EmailParameters,
        $FormattingParameters,
        $ReportOptions,
        [switch] $OutputErrors
    )
    $Errors = @{
        Teams   = $false
        Slack   = $false
        Discord = $false
    }
    $TeamID = Format-FirstXChars -Text $ReportOptions.NotificationsTeams.TeamsID -NumberChars 25
    $SlackID = Format-FirstXChars -Text $ReportOptions.NotificationsSlack.Uri -NumberChars 25
    $DiscordID = Format-FirstXChars -Text $ReportOptions.NotificationsDiscord.Uri -NumberChars 25

    Write-Verbose "Start-ReportBlackLists - TeamsID: $TeamID"
    Write-Verbose "Start-ReportBlackLists - SlackID: $SlackID"
    Write-Verbose "Start-ReportBlackLists - DiscordID: $DiscordID"

    $Ips = foreach ($ip in $ReportOptions.MonitoredIps.Values) {
        $ip
    }

    if ($null -eq $ReportOptions.NotificationsEmail) {
        # Not upgraded config / Legacy config
        $ReportOptions.NotificationsEmail = @{
            Use                          = $true
            EmailPriorityWhenBlacklisted = $ReportOptions.EmailPriorityWhenBlacklisted
            EmailPriorityStandard        = $ReportOptions.EmailPriorityStandard
            EmailAllResults              = $ReportOptions.EmailAllResults
            EmailAlways                  = $ReportOptions.EmailAlways
        }
    }

    $Time = Measure-Command -Expression {
        if ($null -eq $ReportOptions.SortBy) {
            $ReportOptions.SortBy = 'IsListed'
        }
        if ($null -eq $ReportOptions.SortDescending) {
            $ReportOptions.SortDescending = $true
        }

        if ($ReportOptions.NotificationsEmail.EmailAllResults) {
            $BlackListCheck = Search-BlackList -IP $Ips -SortBy $ReportOptions.SortBy -SortDescending:$ReportOptions.SortDescending -ReturnAll -Verbose
        } else {
            $BlackListCheck = Search-BlackList -IP $Ips -SortBy $ReportOptions.SortBy -SortDescending:$ReportOptions.SortDescending -Verbose
        }
    }
    $EmailBody = @(
        Set-EmailHead -FormattingOptions $FormattingParameters
        Set-EmailReportBranding -FormattingOptions $FormattingParameters
        Set-EmailReportDetails -FormattingOptions $FormattingParameters -ReportOptions $ReportOptions -TimeToGenerate $Time
        Set-EmailBody -TableData $BlackListCheck -TableWelcomeMessage 'Following blacklisted servers'
    )

    if ($BlackListCheck.IsListed -contains $true) {
        $EmailParameters.EmailPriority = $ReportOptions.NotificationsEmail.EmailPriorityWhenBlacklisted
    } else {
        $EmailParameters.EmailPriority = $ReportOptions.NotificationsEmail.EmailPriorityStandard
    }


    if ($ReportOptions.NotificationsEmail.Use) {
        if ($ReportOptions.EmailAlways -eq $true -or $BlackListCheck.IsListed -contains $true) {
            if ($FormattingParameters.CompanyBranding.Inline) {
                $SendMail = Send-Email -EmailParameters $EmailParameters -Body $EmailBody -InlineAttachments @{logo = $FormattingParameters.CompanyBranding.Logo} -Verbose
            } else {
                $SendMail = Send-Email -EmailParameters $EmailParameters -Body $EmailBody
            }
        }
    }

    if ($BlackListCheck.IsListed -contains $true) {
        $BlackListLimited = $BlackListCheck | Where-Object { $_.IsListed -eq $true }

        if ($ReportOptions.NotificationsTeams.Use) {
            [string] $MessageTitle = $ReportOptions.NotificationsTeams.MessageTitle
            [string] $ActivityImageLink = $ReportOptions.NotificationsTeams.MessageImageLink

            [RGBColors] $Color = [RGBColors]::Red
            $Sections = @(
                foreach ($Server in $BlackListLimited) {
                    [string] $ActivityTitle = "Blacklisted IP **$($Server.IP)**"
                    if ($ReportOptions.NotificationsTeams.MessageButtons) {
                        $Button1 = New-TeamsButton -Name "Check BlackList" -Link "https://mxtoolbox.com/SuperTool.aspx?action=blacklist%3a$($Server.Ip)&run=toolpage"
                        $Button2 = New-TeamsButton -Name "Check SMTP" -Link "https://mxtoolbox.com/SuperTool.aspx?action=smtp%3a$($Server.Ip)&run=toolpage"

                        New-TeamsSection `
                            -ActivityTitle $ActivityTitle `
                            -ActivitySubtitle "Found on blacklist **$($Server.Blacklist)**" `
                            -ActivityImageLink $ActivityImageLink `
                            -ActivityText "Everybody panic!" `
                            -Buttons $Button1, $Button2
                    } else {
                        New-TeamsSection `
                            -ActivityTitle $ActivityTitle `
                            -ActivitySubtitle "Found on blacklist **$($Server.Blacklist)**" `
                            -ActivityImageLink $ActivityImageLink `
                            -ActivityText "Responses: $($Server.Answer)"
                    }
                }
            )

            try {
                $TeamsOutput = Send-TeamsMessage `
                    -URI $ReportOptions.NotificationsTeams.TeamsID `
                    -MessageTitle $MessageTitle `
                    -Color $Color `
                    -Sections $Sections `
                    -Supress $false
            } catch {
                $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
                Write-Warning "Couldn't send to Teams - Error occured: $ErrorMessage"
                $Errors.Teams = $true
            }
            #Write-Color @script:WriteParameters -Text "[i] Teams output: ", $Data -Color White, Yellow
        }
        if ($ReportOptions.NotificationsSlack.Use) {

            $MessageTitle = $ReportOptions.NotificationsSlack.MessageTitle
            [string] $ActivityImageLink = $ReportOptions.NotificationsSlack.MessageImageLink

            $Attachments = @(
                foreach ($Server in $BlackListLimited) {
                    New-SlackMessageAttachment -Color $_PSSlackColorMap.red `
                        -Title "IP $($Server.IP) is Blacklisted" `
                        -TitleLink "https://mxtoolbox.com/SuperTool.aspx?action=blacklist%3a$($Server.Ip)&run=toolpage" `
                        -Text $ReportOptions.NotificationsSlack.MessageText `
                        -Pretext "Found on blacklist $($Server.Blacklist)" `
                        -Fallback 'Your client is bad'
                }
            )

            try {
                $SlackOutput = New-SlackMessage -Attachments $Attachments `
                    -Channel $ReportOptions.NotificationsSlack.Channel `
                    -IconEmoji $ReportOptions.NotificationsSlack.MessageEmoji `
                    -AsUser `
                    -Username $ReportOptions.NotificationsSlack.MessageAsUser | `
                    Send-SlackMessage -Uri $ReportOptions.NotificationsSlack.URI
            } catch {
                $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
                Write-Warning "Couldn't send to Slack - Error occured: $ErrorMessage"
                $Errors.Slack = $true
            }
            #Write-Color @script:WriteParameters -Text "[i] Slack output: ", $Data -Color White, Yellow
        }

        if ($ReportOptions.NotificationsDiscord.Use) {
            if ($null -eq $ReportOptions.NotificationsDiscord.MessageInline) {
                $ReportOptions.NotificationsDiscord.MessageInline = $false
            }

            try {
                $Facts = foreach ($Server in $BlackListLimited) {
                    [string] $ActivityTitle = "Blacklisted IP $($Server.IP)"
                    [string] $ActivityValue = "Found on blacklist $($Server.Blacklist)"

                    New-DiscordFact -Name $ActivityTitle -Value $ActivityValue -Inline $ReportOptions.NotificationsDiscord.MessageInline
                }

                $Thumbnail = New-DiscordThumbnail -Url $ReportOptions.NotificationsDiscord.MessageImageLink
                $Author = New-DiscordAuthor -Name 'PSBlacklistChecker' -IconUrl  $ReportOptions.NotificationsDiscord.MessageImageLink
                $Section = New-DiscordSection -Title $ReportOptions.NotificationsDiscord.MessageText `
                    -Description '' `
                    -Facts $Facts `
                    -Color $ReportOptions.NotificationsDiscord.MessageColor `
                    -Author $Author `
                    -Thumbnail $Thumbnail #-Image $Thumbnail

                Send-DiscordMessage -WebHookUrl $ReportOptions.NotificationsDiscord.Uri `
                    -Sections $Section `
                    -AvatarName $ReportOptions.NotificationsDiscord.MessageAsUser `
                    -AvatarUrl $ReportOptions.NotificationsDiscord.MessageAsUserImage -Verbose

            } catch {
                $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
                Write-Warning "Couldn't send to Discord - Error occured: $ErrorMessage"
                $Errors.Discord = $true
            }
        }
        if ($OutputErrors) {
            return $Errors
        }
    }
}