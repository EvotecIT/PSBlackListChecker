Clear-Host
Import-Module "C:\Support\GitHub\PSPublishModule\PSPublishModule.psm1" -Force

$Configuration = @{
    Information = @{
        ModuleName        = 'PSBlackListChecker'

        DirectoryProjects = 'C:\Support\GitHub'
        #DirectoryModules  = "C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules"
        #DirectoryModules  = "$Env:USERPROFILE\Documents\WindowsPowerShell\Modules"

        FunctionsToExport = 'Public'
        AliasesToExport   = 'Public'

        #LibrariesCore     = ''
        #LibrariesDefault  = ''
        #ScriptsToProcess  = 'Enums'

        Manifest          = @{
            #Path                 = "C:\Support\GitHub\PSBlackListChecker\PSBlackListChecker.psd1"

            # Script module or binary module file associated with this manifest.
            #RootModule           = 'PSBlackListChecker.psm1'

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

            # Modules that must be imported into the global environment prior to importing this module
            RequiredModules      = @(
                @{ ModuleName = 'PSSharedGoods'; ModuleVersion = "Latest"; Guid = 'ee272aa8-baaa-4edf-9f45-b6d6f7d844fe' }
                @{ ModuleName = 'PSSlack'; ModuleVersion = "Latest"; Guid = 'fb0a1f73-e16c-4829-b2a7-4fc8d7bed545' }
                @{ ModuleName = 'PSTeams'; ModuleVersion = "Latest"; Guid = 'a46c3b0b-5687-4d62-89c5-753ae01e0926' }
                @{ ModuleName = 'PSDiscord'; ModuleVersion = "Latest"; Guid = 'd5ae39b1-56a4-4f43-b251-e402b0c3c485' }
            )
            #ExternalModuleDependencies = @(
            #"DnsClient"
            #"Microsoft.PowerShell.Utility"
            #"Microsoft.PowerShell.Security"
            #"Microsoft.PowerShell.Management"
            #)
        }
    }
    Options     = @{
        Merge             = @{
            Sort           = 'None'
            FormatCodePSM1 = @{
                Enabled           = $true
                RemoveComments    = $true
                FormatterSettings = @{
                    IncludeRules = @(
                        'PSPlaceOpenBrace',
                        'PSPlaceCloseBrace',
                        'PSUseConsistentWhitespace',
                        'PSUseConsistentIndentation',
                        'PSAlignAssignmentStatement',
                        'PSUseCorrectCasing'
                    )

                    Rules        = @{
                        PSPlaceOpenBrace           = @{
                            Enable             = $true
                            OnSameLine         = $true
                            NewLineAfter       = $true
                            IgnoreOneLineBlock = $true
                        }

                        PSPlaceCloseBrace          = @{
                            Enable             = $true
                            NewLineAfter       = $false
                            IgnoreOneLineBlock = $true
                            NoEmptyLineBefore  = $false
                        }

                        PSUseConsistentIndentation = @{
                            Enable              = $true
                            Kind                = 'space'
                            PipelineIndentation = 'IncreaseIndentationAfterEveryPipeline'
                            IndentationSize     = 4
                        }

                        PSUseConsistentWhitespace  = @{
                            Enable          = $true
                            CheckInnerBrace = $true
                            CheckOpenBrace  = $true
                            CheckOpenParen  = $true
                            CheckOperator   = $true
                            CheckPipe       = $true
                            CheckSeparator  = $true
                        }

                        PSAlignAssignmentStatement = @{
                            Enable         = $true
                            CheckHashtable = $true
                        }

                        PSUseCorrectCasing         = @{
                            Enable = $true
                        }
                    }
                }
            }
            FormatCodePSD1 = @{
                Enabled        = $true
                RemoveComments = $false
            }
            Integrate      = @{
                ApprovedModules = @('PSSharedGoods', 'PSWriteColor', 'Connectimo', 'PSUnifi', 'PSWebToolbox', 'PSMyPassword')
            }
        }
        Standard          = @{
            FormatCodePSM1 = @{

            }
            FormatCodePSD1 = @{
                Enabled = $true
                #RemoveComments = $true
            }
        }
        ImportModules     = @{
            Self            = $true
            RequiredModules = $false
            Verbose         = $false
        }
        PowerShellGallery = @{
            ApiKey   = 'C:\Support\Important\PowerShellGalleryAPI.txt'
            FromFile = $true
        }
        Documentation     = @{
            Path       = 'Docs'
            PathReadme = 'Docs\Readme.md'
        }
    }
    Steps       = @{
        BuildModule        = @{  # requires Enable to be on to process all of that
            Enable           = $true
            DeleteBefore     = $false
            Merge            = $true
            MergeMissing     = $true
            SignMerged       = $true
            Releases         = $true
            ReleasesUnpacked = $false
            RefreshPSD1Only  = $false
        }
        BuildDocumentation = $true
        ImportModules      = @{
            Self            = $true
            RequiredModules = $false
            Verbose         = $false
        }
        PublishModule      = @{  # requires Enable to be on to process all of that
            Enabled      = $false
            Prerelease   = ''
            RequireForce = $false
            GitHub       = $false
        }
    }
}

New-PrepareModule -Configuration $Configuration #-Verbose