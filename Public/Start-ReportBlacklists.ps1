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
        if ($ReportOptions.NotificationsEmail.EmailAllResults) {
            $BlackListCheck = Search-BlackList -IP $Ips -SortBy $ReportOptions.SortBy -SortDescending:$ReportOptions.SortDescending -ReturnAll
        } else {
            $BlackListCheck = Search-BlackList -IP $Ips -SortBy $ReportOptions.SortBy -SortDescending:$ReportOptions.SortDescending
        }
    }
    $EmailBody += Set-EmailReportDetails -FormattingOptions $FormattingParameters -ReportOptions $ReportOptions -TimeToGenerate $Time
    $EmailBody += Set-EmailBody -TableData $BlackListCheck -TableWelcomeMessage 'Following blacklisted servers'

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
            $Sections = @()
            foreach ($Server in $BlackListLimited) {
                [string] $ActivityTitle = "Blacklisted IP **$($Server.IP)**"
                if ($ReportOptions.NotificationsTeams.MessageButtons) {
                    $Button1 = New-TeamsButton -Name "Check BlackList" -Link "https://mxtoolbox.com/SuperTool.aspx?action=blacklist%3a$($Server.Ip)&run=toolpage"
                    $Button2 = New-TeamsButton -Name "Check SMTP" -Link "https://mxtoolbox.com/SuperTool.aspx?action=smtp%3a$($Server.Ip)&run=toolpage"

                    $Sections += New-TeamsSection `
                        -ActivityTitle $ActivityTitle `
                        -ActivitySubtitle "Found on blacklist **$($Server.Blacklist)**" `
                        -ActivityImageLink $ActivityImageLink `
                        -ActivityText "Everybody panic!" `
                        -Buttons $Button1, $Button2
                } else {
                    $Sections += New-TeamsSection `
                        -ActivityTitle $ActivityTitle `
                        -ActivitySubtitle "Found on blacklist **$($Server.Blacklist)**" `
                        -ActivityImageLink $ActivityImageLink `
                        -ActivityText "Responses: $($Server.Answer)"
                }
            }

            $TeamsOutput = Send-TeamsMessage `
                -URI $ReportOptions.NotificationsTeams.TeamsID `
                -MessageTitle $MessageTitle `
                -Color $Color `
                -Sections $Sections `
                -Supress $false
            #Write-Color @script:WriteParameters -Text "[i] Teams output: ", $Data -Color White, Yellow
        }
        if ($ReportOptions.NotificationsSlack.Use) {
            $MessageTitle = $ReportOptions.NotificationsSlack.MessageTitle
            [string] $ActivityImageLink = $ReportOptions.NotificationsSlack.MessageImageLink

            $Attachments = @()
            foreach ($Server in $BlackListLimited) {
                $Attachments += New-SlackMessageAttachment -Color $_PSSlackColorMap.red `
                    -Title "IP $($Server.IP) is Blacklisted" `
                    -TitleLink "https://mxtoolbox.com/SuperTool.aspx?action=blacklist%3a$($Server.Ip)&run=toolpage" `
                    -Text $ReportOptions.NotificationsSlack.MessageText `
                    -Pretext "Found on blacklist $($Server.Blacklist)" `
                    -Fallback 'Your client is bad'
            }

            $SlackOutput = New-SlackMessage -Attachments $Attachments `
                -Channel $ReportOptions.NotificationsSlack.Channel `
                -IconEmoji $ReportOptions.NotificationsSlack.MessageEmoji `
                -AsUser `
                -Username $ReportOptions.NotificationsSlack.MessageAsUser | `
                Send-SlackMessage -Uri $ReportOptions.NotificationsSlack.URI
            #Write-Color @script:WriteParameters -Text "[i] Slack output: ", $Data -Color White, Yellow
        }

        if ($ReportOptions.NotificationsDiscord.Use) {
            try {
                $EmbedBuilder = [DiscordEmbed]::New('', $ReportOptions.NotificationsDiscord.MessageText)
                foreach ($Server in $BlackListLimited) {
                    [string] $ActivityTitle = "Blacklisted IP $($Server.IP)"
                    [string] $ActivityValue = "Found on blacklist $($Server.Blacklist)"

                    $embedBuilder.AddField(
                        [DiscordField]::New(
                            $ActivityTitle,
                            $ActivityValue,
                            $false
                        )
                    )
                }
                $EmbedBuilder.WithColor([DiscordColor]::New($ReportOptions.NotificationsDiscord.MessageColor)  )
                $EmbedBuilder.AddAuthor([DiscordAuthor]::New('PSBlackListChecker', $ReportOptions.NotificationsDiscord.MessageImageLink ))
                $EmbedBuilder.AddThumbnail([DiscordThumbnail]::New($ReportOptions.NotificationsDiscord.MessageImageLink))

                Invoke-PSDsHook -WebhookUrl $ReportOptions.NotificationsDiscord.Uri -EmbedObject $embedBuilder
            } catch {
                $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
                if ($ErrorMessage -like '*DiscordEmbed*') {
                    Write-Warning "Couldn't send to Discord - Remember to Install PSDsHook module and add 'using module PSDsHook' to the top of starting script."
                } else {
                    Write-Warning "Couldn't send to Discord - Error occured: $ErrorMessage"
                }
            }

        }

    }
}