#Requires -Version 5.1
<#
.SYNOPSIS
Checks the Stage 00 Android baseline and writes a sanitized evidence report.
.PARAMETER SdkRoot
Local SDK directory. Defaults to ANDROID_HOME, then the standard user location.
#>
[CmdletBinding()]
param(
    [string]$SdkRoot = $(if ($env:ANDROID_HOME) { $env:ANDROID_HOME } else { "$env:LOCALAPPDATA\Android\Sdk" })
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$repoRoot = Split-Path $PSScriptRoot -Parent
$evidenceDir = Join-Path $repoRoot 'stages\00-dev-environment\evidence'
New-Item -ItemType Directory -Path $evidenceDir -Force | Out-Null
$checks = New-Object System.Collections.Generic.List[object]
function Add-Check([string]$Name, [bool]$Passed, [string]$Detail, [bool]$Required = $true) {
    $checks.Add([pscustomobject]@{ name=$Name; passed=$Passed; required=$Required; detail=$Detail })
    $state = if ($Passed) { 'PASS' } elseif ($Required) { 'FAIL' } else { 'WARN' }
    Write-Host ("[{0}] {1}: {2}" -f $state, $Name, $Detail)
}
function Invoke-Probe {
    param([string]$Executable, [string[]]$Arguments)
    if (-not $Executable -or -not (Test-Path -LiteralPath $Executable -PathType Leaf)) {
        return [pscustomobject]@{ Passed=$false; Output='' }
    }
    # Windows PowerShell represents native stderr as ErrorRecord objects.
    $savedPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $output = (& $Executable @Arguments 2>&1 | Out-String)
        $code = $LASTEXITCODE
        return [pscustomobject]@{ Passed=($code -eq 0); Output=$output }
    } catch {
        return [pscustomobject]@{ Passed=$false; Output='' }
    } finally { $ErrorActionPreference = $savedPreference }
}
function Test-PhoneAvd($Probe) {
    if (-not $Probe.Passed) { return $false }
    $block = ($Probe.Output -split '(?m)^\s*Name:\s+') | Where-Object { $_ -match '^KiteKeep_Phone_API36\s' } | Select-Object -First 1
    if (-not $block -or $block -notmatch '(?m)^\s*Path:\s*(.+?)\s*$') { return $false }
    $config = Join-Path $matches[1].Trim() 'config.ini'
    if (-not (Test-Path -LiteralPath $config -PathType Leaf)) { return $false }
    $content = Get-Content -LiteralPath $config -Raw
    return [bool]($content -match '(?m)^image\.sysdir\.1\s*=\s*system-images[\\/]android-36[\\/]google_apis[\\/]x86_64[\\/]?\s*$')
}
function Add-ToolCheck([string]$Name, $Probe) {
    $detail = if ($Probe.Passed) { 'command succeeded' } else { 'missing or command failed; rerun setup' }
    Add-Check $Name $Probe.Passed $detail
}
$git = Get-Command git -ErrorAction SilentlyContinue
$gitPath = if ($git) { $git.Source } else { '' }
Add-ToolCheck 'Git' (Invoke-Probe $gitPath @('--version'))
$studio = 'C:\Program Files\Android\Android Studio\bin\studio64.exe'
Add-Check 'Android Studio' (Test-Path -LiteralPath $studio -PathType Leaf) 'standard installation required'
$javaExe = ''
if ($env:JAVA_HOME) { $javaExe = Join-Path $env:JAVA_HOME 'bin\java.exe' }
if (-not $javaExe) {
    $javaCommand = Get-Command java -ErrorAction SilentlyContinue
    if ($javaCommand) { $javaExe = $javaCommand.Source }
}
$java = Invoke-Probe $javaExe @('-version')
$javaMajor = 0
if ($java.Output -match 'version\s+"(\d+)') { $javaMajor = [int]$matches[1] }
Add-Check 'Java' ($java.Passed -and $javaMajor -ge 17) 'working Java 17+ required'
$sdkManager = Join-Path $SdkRoot 'cmdline-tools\latest\bin\sdkmanager.bat'
$adb = Join-Path $SdkRoot 'platform-tools\adb.exe'
$emulator = Join-Path $SdkRoot 'emulator\emulator.exe'
Add-ToolCheck 'Android SDK manager' (Invoke-Probe $sdkManager @('--version'))
Add-ToolCheck 'ADB' (Invoke-Probe $adb @('version'))
Add-ToolCheck 'Android Emulator' (Invoke-Probe $emulator @('-version'))
foreach ($api in 28,31,34,36) {
    $jar = Join-Path $SdkRoot "platforms\android-$api\android.jar"
    Add-Check "Android platform API $api" (Test-Path -LiteralPath $jar -PathType Leaf) 'platform android.jar required'
}
Add-ToolCheck 'Build Tools 36.0.0' (Invoke-Probe (Join-Path $SdkRoot 'build-tools\36.0.0\aapt2.exe') @('version'))
$avdManager = Join-Path $SdkRoot 'cmdline-tools\latest\bin\avdmanager.bat'
$avds = Invoke-Probe $avdManager @('list','avd')
$phoneValid = Test-PhoneAvd $avds
Add-Check 'Phone AVD' $phoneValid 'API 36 phone AVD required; document any host limitation in HANDOFF.md'
Add-Check 'Tablet AVD' ($avds.Passed -and $avds.Output -match '(?m)^\s*Name:\s+KiteKeep_Tablet_API36\s*$') 'optional tablet AVD' $false
try {
    $virt = Get-CimInstance Win32_Processor | Select-Object -First 1 -ExpandProperty VirtualizationFirmwareEnabled
    Add-Check 'Hardware virtualization' ([bool]$virt) 'firmware virtualization capability' $false
} catch { Add-Check 'Hardware virtualization' $false 'unable to query host; check firmware settings' $false }
# Do not enumerate connected devices: serials and device metadata are not needed.
$requiredFailures = @($checks | Where-Object { $_.required -and -not $_.passed })
$report = [pscustomobject]@{
    generated_utc = (Get-Date).ToUniversalTime().ToString('o')
    stage = '00-dev-environment'
    required_passed = ($requiredFailures.Count -eq 0)
    checks = $checks
}
$report | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $evidenceDir 'environment-report.json') -Encoding UTF8
Write-Host 'Evidence report: stages/00-dev-environment/evidence/environment-report.json'
if ($requiredFailures.Count -gt 0) {
    Write-Host "$($requiredFailures.Count) required environment check(s) failed. Run scripts/setup-dev-environment.ps1, then rerun verification."
    exit 1
}
Write-Host 'All required KiteKeep development environment checks passed.'
exit 0

