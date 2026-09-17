#Requires -Version 5.1
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = Split-Path $PSScriptRoot -Parent
$results = New-Object System.Collections.Generic.List[string]
function Assert-Result([bool]$Condition, [string]$Name) {
    if (-not $Condition) { throw "FAIL: $Name" }
    $results.Add("PASS: $Name")
}
$asts = @{}
foreach ($name in 'setup-dev-environment.ps1','verify-dev-environment.ps1') {
    $tokens=$null; $errors=$null
    $asts[$name] = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $PSScriptRoot $name),[ref]$tokens,[ref]$errors)
    Assert-Result ($errors.Count -eq 0) "$name parses in Windows PowerShell"
}
# Load only the pure/probe functions, without running installation or verification.
$functions = $asts['verify-dev-environment.ps1'].FindAll({param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst]},$true)
foreach ($name in 'Invoke-Probe','Test-PhoneAvd') {
    $definition = $functions | Where-Object Name -eq $name | Select-Object -First 1
    . ([scriptblock]::Create($definition.Extent.Text))
}
$pathHelper = $asts['setup-dev-environment.ps1'].FindAll({param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Get-UpdatedUserPath'},$true) | Select-Object -First 1
. ([scriptblock]::Create($pathHelper.Extent.Text))
$nativeHelper = $asts['setup-dev-environment.ps1'].FindAll({param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Invoke-AndroidCommand'},$true) | Select-Object -First 1
. ([scriptblock]::Create($nativeHelper.Extent.Text))
$temp = Join-Path $env:TEMP ('kitekeep-tests-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $temp | Out-Null
try {
    $ok = Join-Path $temp 'ok.cmd'
    $bad = Join-Path $temp 'bad.cmd'
    "@echo off`r`necho version-test 1>&2`r`nexit /b 0" | Set-Content -LiteralPath $ok -Encoding ASCII
    "@echo off`r`necho failure`r`nexit /b 7" | Set-Content -LiteralPath $bad -Encoding ASCII
    Assert-Result ((Invoke-AndroidCommand $ok @()) -match 'version-test') 'setup accepts successful native commands with stderr warnings'
    $failed=$false
    try { Invoke-AndroidCommand $bad @() | Out-Null } catch { $failed=$true }
    Assert-Result $failed 'setup rejects native nonzero exits'
    Assert-Result ((Invoke-Probe $ok @()).Passed) 'successful command with stderr passes'
    Assert-Result (-not (Invoke-Probe $bad @()).Passed) 'installed command with nonzero exit fails'
    Assert-Result (-not (Invoke-Probe (Join-Path $temp 'absent.exe') @()).Passed) 'missing executable fails'
    $probe = [pscustomobject]@{ Passed=$true; Output="Name: KiteKeep_Phone_API36`nPath: $temp`n" }
    Assert-Result (-not (Test-PhoneAvd $probe)) 'named AVD without configuration fails'
    'image.sysdir.1=system-images\android-34\google_apis\x86_64\' | Set-Content -LiteralPath (Join-Path $temp 'config.ini')
    Assert-Result (-not (Test-PhoneAvd $probe)) 'wrong API image fails even with correct AVD name'
    'image.sysdir.1=system-images\android-36\google_apis\x86_64\' | Set-Content -LiteralPath (Join-Path $temp 'config.ini')
    Assert-Result (Test-PhoneAvd $probe) 'correct API 36 Google APIs x86_64 AVD passes'
    $probe.Passed=$false
    Assert-Result (-not (Test-PhoneAvd $probe)) 'failed avdmanager cannot pass from partial output'
    $setupText = $asts['setup-dev-environment.ps1'].Extent.Text
    Assert-Result ($setupText -match 'Start-Process[^\r\n]+-Verb RunAs[^\r\n]+-Wait -PassThru' -and $setupText -match 'exit \$child.ExitCode') 'elevation waits and returns child status (static check)'
    Assert-Result ($setupText -notmatch 'create avd --force') 'AVD creation does not overwrite existing definitions (static check)'
    $userPath = 'C:\Tools;C:\Android\Sdk\platform-tools-extra'
    $entry = 'C:\Android\Sdk\platform-tools'
    foreach ($run in 1,2) { $userPath = Get-UpdatedUserPath $userPath @($entry) }
    Assert-Result (@($userPath -split ';' | Where-Object { $_ -eq $entry }).Count -eq 1) 'PATH matching distinguishes prefixes and does not duplicate entries'
    Assert-Result ((Get-UpdatedUserPath 'C:\TOOLS\' @('c:\tools')) -eq 'C:\TOOLS\') 'PATH comparison ignores case and trailing separator'
    Assert-Result ((Get-UpdatedUserPath $null @('C:\Tools')) -eq 'C:\Tools') 'empty user PATH is initialized'
} finally {
    $resolved = [IO.Path]::GetFullPath($temp)
    $allowed = [IO.Path]::GetFullPath($env:TEMP).TrimEnd('\') + '\'
    if (-not $resolved.StartsWith($allowed,[StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe test cleanup path' }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}
$results | Set-Content -LiteralPath (Join-Path $root 'stages/00-dev-environment/evidence/script-tests.txt') -Encoding UTF8
$results | ForEach-Object { Write-Host $_ }


