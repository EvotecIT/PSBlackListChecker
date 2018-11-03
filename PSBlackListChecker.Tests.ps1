param (
    $TeamsID = $Env:TEAMSPESTERID,
    $SlackID = $Env:SLACKPESTERID
)
$PSVersionTable.PSVersion

$ModuleName = (Get-ChildItem $PSScriptRoot\*.psd1).BaseName

$Pester = (Get-Module -ListAvailable pester)
if ($null -eq $Pester -or ($Pester[0].Version.Major -le 4 -and $Pester[0].Version.Minor -lt 4)) {
    Write-Warning "$ModuleName - Downloading Pester from PSGallery"
    Install-Module -Name Pester -Repository PSGallery -Force -SkipPublisherCheck -Scope CurrentUser
}

$RequiredModules = (Get-Content -Raw $PSScriptRoot\*.psd1)  | Invoke-Expression | ForEach-Object RequiredModules
foreach ($Module in $RequiredModules) {
    $ModuleFound = Get-Module -ListAvailable $Module
    if ($null -eq $ModuleFound) {
        Write-Warning "$ModuleName - Downloading $Module from PSGallery"
        Install-Module -Name $Module -Repository PSGallery -Force -Scope CurrentUser
    }
}

$result = Invoke-Pester -Script @{ Path = "$($PSScriptRoot)\Tests"; Parameters = @{ TeamsID = $TeamsID; SlackID = $SlackID } } -EnableExit

if ($result.FailedCount -gt 0) {
    throw "$($result.FailedCount) tests failed."
}