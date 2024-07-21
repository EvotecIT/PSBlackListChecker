@{
    AliasesToExport      = @()
    Author               = 'Przemyslaw Klys'
    CmdletsToExport      = @()
    CompanyName          = 'Evotec'
    CompatiblePSEditions = @('Desktop', 'Core')
    Copyright            = '(c) 2011 - 2024 Przemyslaw Klys @ Evotec. All rights reserved.'
    Description          = 'This module allows you to easily check if your defined list of IPs are on any of defined blacklists.
It additionally allows you to easily setup Task Scheduled monitoring and send you reports daily / hourly or weekly if needed.
In new version you now have ability to send notificatins to Microsoft Teams, Slack and Discord.
        '
    FunctionsToExport    = @('Search-BlackList', 'Start-ReportBlackLists')
    GUID                 = '2a79c18e-b153-48b9-9f6c-164d00caa1cb'
    ModuleVersion        = '0.8.7'
    PowerShellVersion    = '5.1'
    PrivateData          = @{
        PSData = @{
            IconUri    = 'https://evotec.xyz/wp-content/uploads/2018/10/PSBlackListChecker.png'
            ProjectUri = 'https://github.com/EvotecIT/PSBlackListChecker'
            Tags       = @('blacklist', 'exchange', 'dnsbl', 'msexchange', 'microsoft', 'slack', 'teams', 'discord', 'windows')
        }
    }
    RequiredModules      = @(@{
            Guid          = '0b0ba5c5-ec85-4c2b-a718-874e55a8bc3f'
            ModuleName    = 'PSWriteColor'
            ModuleVersion = '1.0.1'
        }, @{
            Guid          = 'ee272aa8-baaa-4edf-9f45-b6d6f7d844fe'
            ModuleName    = 'PSSharedGoods'
            ModuleVersion = '0.0.294'
        }, @{
            Guid          = 'a46c3b0b-5687-4d62-89c5-753ae01e0926'
            ModuleName    = 'PSTeams'
            ModuleVersion = '2.4.0'
        }, @{
            Guid          = 'd5ae39b1-56a4-4f43-b251-e402b0c3c485'
            ModuleName    = 'PSDiscord'
            ModuleVersion = '0.2.4'
        })
    RootModule           = 'PSBlackListChecker.psm1'
}