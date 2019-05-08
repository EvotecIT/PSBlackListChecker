param (
    $TeamsID = $Env:TEAMSPESTERID,
    $SlackID = $Env:SLACKPESTERID,
    $DiscordID = $Env:DISCORDURL
)
$PSVersionTable.PSVersion

$ModuleName = (Get-ChildItem -Path $PSScriptRoot\*.psd1).BaseNam
$ModulePath = (Get-ChildItem -Path $PSScriptRoot\*.psd1).FullName

$Pester = (Get-Module -ListAvailable pester)
if ($null -eq $Pester -or ($Pester[0].Version.Major -le 4 -and $Pester[0].Version.Minor -lt 4)) {
    Write-Warning "$ModuleName - Downloading Pester from PSGallery"
    Install-Module -Name Pester -Repository PSGallery -Force -SkipPublisherCheck -Scope CurrentUser
}


    $RequiredModules = (Get-Content -Raw $PSScriptRoot\*.psd1)  | Invoke-Expression | ForEach-Object RequiredModules
    foreach ($Module in $RequiredModules) {
        if ($Module -is [hashtable]) {
            $ModuleRequiredName = $Module.ModuleName
        } elseif ($Module) {
            $ModuleRequiredName = $Module
        }
        $ModuleFound = Get-Module -ListAvailable $ModuleRequiredName
        if ($null -eq $ModuleFound) {
            Write-Warning "$ModuleName - Downloading $ModuleRequiredName from PSGallery"
            Install-Module -Name $ModuleRequiredName -Repository PSGallery -Force -Scope CurrentUser
        }
    }
Import-Module -Name $ModulePath -Force -ErrorAction Stop

$result = Invoke-Pester -Script @{ Path = "$($PSScriptRoot)\Tests"; Parameters = @{ TeamsID = $TeamsID; SlackID = $SlackID; DiscordID = $DiscordID } } -EnableExit

if ($result.FailedCount -gt 0) {
    throw "$($result.FailedCount) tests failed."
}