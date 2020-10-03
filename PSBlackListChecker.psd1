@{
    AliasesToExport      = @()
    Author               = 'Przemyslaw Klys'
    CmdletsToExport      = @()
    CompanyName          = 'Evotec'
    CompatiblePSEditions = @('Desktop', 'Core')
    Copyright            = '(c) 2011 - 2020 Przemyslaw Klys @ Evotec. All rights reserved.'
    Description          = 'This module allows you to easily check if your defined list of IPs are on any of defined blacklists.
It additionally allows you to easily setup Task Scheduled monitoring and send you reports daily / hourly or weekly if needed.
In new version you now have ability to send notificatins to Microsoft Teams, Slack and Discord.
            '
    FunctionsToExport    = @('Search-BlackList', 'Start-ReportBlackLists')
    GUID                 = '2a79c18e-b153-48b9-9f6c-164d00caa1cb'
    ModuleVersion        = '0.8.6'
    PowerShellVersion    = '5.1'
    PrivateData          = @{
        PSData = @{
            Tags       = @('blacklist', 'exchange', 'dnsbl', 'msexchange', 'microsoft', 'slack', 'teams', 'discord', 'windows')
            ProjectUri = 'https://github.com/EvotecIT/PSBlackListChecker'
            IconUri    = 'https://evotec.xyz/wp-content/uploads/2018/10/PSBlackListChecker.png'
        }
    }
    RequiredModules      = @(@{
            ModuleVersion = '0.0.180'
            ModuleName    = 'PSSharedGoods'
            Guid          = 'ee272aa8-baaa-4edf-9f45-b6d6f7d844fe'
        }, @{
            ModuleVersion = '1.0.5'
            ModuleName    = 'PSSlack'
            Guid          = 'fb0a1f73-e16c-4829-b2a7-4fc8d7bed545'
        }, @{
            ModuleVersion = '1.0.5'
            ModuleName    = 'PSTeams'
            Guid          = 'a46c3b0b-5687-4d62-89c5-753ae01e0926'
        }, @{
            ModuleVersion = '0.2.2'
            ModuleName    = 'PSDiscord'
            Guid          = 'd5ae39b1-56a4-4f43-b251-e402b0c3c485'
        })
    RootModule           = 'PSBlackListChecker.psm1'
}