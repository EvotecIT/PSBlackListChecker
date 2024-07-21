Clear-Host

Invoke-ModuleBuild -ModuleName 'PSBlackListChecker' {
    # Usual defaults as per standard module
    $Manifest = @{
        # Version number of this module.
        ModuleVersion        = '0.8.X'

        # ID used to uniquely identify this module
        GUID                 = '2a79c18e-b153-48b9-9f6c-164d00caa1cb'
        # Author of this module
        Author               = 'Przemyslaw Klys'
        # Company or vendor of this module
        CompanyName          = 'Evotec'
        # Copyright statement for this module
        Copyright            = "(c) 2011 - $((Get-Date).Year) Przemyslaw Klys @ Evotec. All rights reserved."

        # Minimum version of the Windows PowerShell engine required by this module
        PowerShellVersion    = '5.1'

        # Supported PSEditions
        CompatiblePSEditions = @('Desktop', 'Core')

        Description          = "This module allows you to easily check if your defined list of IPs are on any of defined blacklists.
It additionally allows you to easily setup Task Scheduled monitoring and send you reports daily / hourly or weekly if needed.
In new version you now have ability to send notificatins to Microsoft Teams, Slack and Discord.
        "
        # Tags applied to this module. These help with module discovery in online galleries.
        Tags                 = 'blacklist', 'exchange', 'dnsbl', 'msexchange', 'microsoft', 'slack', 'teams', 'discord', 'windows'

        # A URL to the main website for this project.
        ProjectUri           = 'https://github.com/EvotecIT/PSBlackListChecker'

        # A URL to an icon representing this module.
        IconUri              = 'https://evotec.xyz/wp-content/uploads/2018/10/PSBlackListChecker.png'
    }
    New-ConfigurationManifest @Manifest

    New-ConfigurationModule -Type RequiredModule -Name 'PSWriteColor' -Guid Auto -Version Latest
    New-ConfigurationModule -Type RequiredModule -Name @(
        'PSSharedGoods'
        'PSTeams'
        'PSDiscord'
    ) -Guid Auto -Version Latest

    New-ConfigurationModule -Type ApprovedModule -Name 'PSWriteColor', 'Connectimo', 'PSUnifi', 'PSWebToolbox', 'PSMyPassword', 'PSSharedGoods'

    New-ConfigurationModuleSkip -IgnoreModuleName @(
        'Microsoft.PowerShell.Security'
        'DnsClient'
        'PSSlack'
    ) -IgnoreFunctionName 'New-SlackMessage', 'New-SlackMessageAttachment', 'Send-SlackMessage'

    $ConfigurationFormat = [ordered] @{
        RemoveComments                              = $true
        RemoveEmptyLines                            = $true

        PlaceOpenBraceEnable                        = $true
        PlaceOpenBraceOnSameLine                    = $true
        PlaceOpenBraceNewLineAfter                  = $true
        PlaceOpenBraceIgnoreOneLineBlock            = $false

        PlaceCloseBraceEnable                       = $true
        PlaceCloseBraceNewLineAfter                 = $false
        PlaceCloseBraceIgnoreOneLineBlock           = $false
        PlaceCloseBraceNoEmptyLineBefore            = $true

        UseConsistentIndentationEnable              = $true
        UseConsistentIndentationKind                = 'space'
        UseConsistentIndentationPipelineIndentation = 'IncreaseIndentationAfterEveryPipeline'
        UseConsistentIndentationIndentationSize     = 4

        UseConsistentWhitespaceEnable               = $true
        UseConsistentWhitespaceCheckInnerBrace      = $true
        UseConsistentWhitespaceCheckOpenBrace       = $true
        UseConsistentWhitespaceCheckOpenParen       = $true
        UseConsistentWhitespaceCheckOperator        = $true
        UseConsistentWhitespaceCheckPipe            = $true
        UseConsistentWhitespaceCheckSeparator       = $true

        AlignAssignmentStatementEnable              = $true
        AlignAssignmentStatementCheckHashtable      = $true

        UseCorrectCasingEnable                      = $true
    }
    # format PSD1 and PSM1 files when merging into a single file
    # enable formatting is not required as Configuration is provided
    New-ConfigurationFormat -ApplyTo 'OnMergePSM1', 'OnMergePSD1' -Sort None @ConfigurationFormat
    # format PSD1 and PSM1 files within the module
    # enable formatting is required to make sure that formatting is applied (with default settings)
    New-ConfigurationFormat -ApplyTo 'DefaultPSD1', 'DefaultPSM1' -EnableFormatting -Sort None
    # when creating PSD1 use special style without comments and with only required parameters
    New-ConfigurationFormat -ApplyTo 'DefaultPSD1', 'OnMergePSD1' -PSD1Style 'Minimal'
    # configuration for documentation, at the same time it enables documentation processing
    New-ConfigurationDocumentation -Enable:$false -StartClean -UpdateWhenNew -PathReadme 'Docs\Readme.md' -Path 'Docs'

    New-ConfigurationImportModule -ImportSelf

    New-ConfigurationBuild -Enable:$true -SignModule -MergeModuleOnBuild -MergeFunctionsFromApprovedModules -CertificateThumbprint '483292C9E317AA13B07BB7A96AE9D1A5ED9E7703'

    #New-ConfigurationTest -TestsPath "$PSScriptRoot\..\Tests" -Enable

    New-ConfigurationArtefact -Type Unpacked -Enable -Path "$PSScriptRoot\..\Artefacts\Unpacked" -AddRequiredModules
    New-ConfigurationArtefact -Type Packed -Enable -Path "$PSScriptRoot\..\Artefacts\Packed" -ArtefactName '<ModuleName>.v<ModuleVersion>.zip'

    # options for publishing to github/psgallery
    #New-ConfigurationPublish -Type PowerShellGallery -FilePath 'C:\Support\Important\PowerShellGalleryAPI.txt' -Enabled:$true
    #New-ConfigurationPublish -Type GitHub -FilePath 'C:\Support\Important\GitHubAPI.txt' -UserName 'EvotecIT' -Enabled:$true
} -ExitCode