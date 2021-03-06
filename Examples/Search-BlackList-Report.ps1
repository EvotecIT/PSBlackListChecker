$EmailParameters = @{
    EmailFrom            = "monitoring@domain.pl"
    EmailTo              = "przemyslaw.klys@domain.pl" #
    EmailCC              = ""
    EmailBCC             = ""
    EmailServer          = ""
    EmailServerPassword  = ""
    EmailServerPort      = "587"
    EmailServerLogin     = ""
    EmailServerEnableSSL = 1
    EmailEncoding        = "Unicode"
    EmailSubject         = "[Reporting] Blacklist monitoring"
    EmailPriority        = "Low" # Normal, High
}
$FormattingParameters = @{
    CompanyBrandingTemplate = 'TemplateDefault'
    CompanyBranding         = @{
        Logo   = "https://evotec.xyz/wp-content/uploads/2015/05/Logo-evotec-012.png"
        Width  = "200"
        Height = ""
        Link   = "https://evotec.xyz"
        Inline = $false
    }
    FontFamily              = "Calibri Light"
    FontSize                = "9pt"

    FontHeadingFamily       = "Calibri Light"
    FontHeadingSize         = "12pt"

    FontTableHeadingFamily  = "Calibri Light"
    FontTableHeadingSize    = "9pt"

    FontTableDataFamily     = "Calibri Light"
    FontTableDataSize       = "9pt"
}
$ReportOptions = @{
    SortBy               = 'IsListed' # Options: 'IP', 'BlackList', 'IsListed', 'Answer', 'FQDN
    SortDescending       = $true

    MonitoredIps         = @{
        Ip1 = '89.25.253.1'
        Ip2 = '188.117.129.1'
        # you can add as many Ip's as you want / IP1,2,3,4,5 etc
    }
    NotificationsEmail   = @{
        Use                          = $false
        EmailPriorityWhenBlacklisted = 'High'
        EmailPriorityStandard        = 'Low'
        EmailAllResults              = $false
        EmailAlways                  = $true
    }
    # Module uses PSTeams - it comes embedded with PSBlackListChedcker
    NotificationsTeams   = @{
        Use              = $false
        TeamsID          = ''
        MessageTitle     = 'IP Blacklisted'
        MessageText      = 'Everybody panic!'
        MessageImageLink = 'https://raw.githubusercontent.com/EvotecIT/PSTeams/master/Links/Asset%20130.png'
        MessageButtons   = $true
    }
    # Module uses PSSlack - it comes embedded with PSBlackListChecker
    NotificationsSlack   = @{
        Use            = $false
        Uri            = ""
        MessageTitle   = 'IP Blacklisted'
        MessageText    = 'Everybody panic!'
        MessageButtons = $true
        MessageEmoji   = ':hankey:'  # Emoji List https://www.webpagefx.com/tools/emoji-cheat-sheet/
        MessageAsUser  = 'PSBlackListChecker'
    }
    # Module uses PSDiscord - it comes embedded with PSBlackListChedcker
    NotificationsDiscord = @{
        Use                = $false
        Uri                = 'https://discordapp.com/api/webhooks/...'
        MessageImageLink   = 'https://raw.githubusercontent.com/EvotecIT/PSTeams/master/Links/Asset%20130.png'
        MessageColor       = 'blue'
        MessageText        = 'Everybody panic!'
        MessageAsUser      = 'PSBlackListChecker'
        MessageAsUserImage = 'https://raw.githubusercontent.com/EvotecIT/PSTeams/master/Links/Asset%20130.png'
        MessageInline      = $false
    }
}

Start-ReportBlackLists -EmailParameters $EmailParameters -FormattingParameters $FormattingParameters -ReportOptions $ReportOptions