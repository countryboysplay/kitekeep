#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$SdkRoot = "$env:LOCALAPPDATA\Android\Sdk",
    [string]$CommandLineToolsRevision = "15859902",
    [switch]$SkipAndroidStudio,
    [switch]$SkipAvdCreation
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
Set-StrictMode -Version Latest

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Restart-Elevated {
    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ('"{0}"' -f $PSCommandPath))
    if ($SdkRoot) { $argList += @('-SdkRoot', ('"{0}"' -f $SdkRoot)) }
    if ($CommandLineToolsRevision) { $argList += @('-CommandLineToolsRevision', $CommandLineToolsRevision) }
    if ($SkipAndroidStudio) { $argList += '-SkipAndroidStudio' }
    if ($SkipAvdCreation) { $argList += '-SkipAvdCreation' }
    $child = Start-Process -FilePath 'powershell.exe' -Verb RunAs -WindowStyle Hidden -Wait -PassThru -ArgumentList ($argList -join ' ')
    exit $child.ExitCode
}

if (-not (Test-IsAdministrator)) {
    Write-Host 'Administrator privileges are required for initial KiteKeep tooling setup. Requesting elevation...'
    Restart-Elevated
}

function Get-UpdatedUserPath {
    param([AllowNull()][string]$CurrentPath, [string[]]$Entries)
    foreach ($entry in $Entries) {
        if (@($CurrentPath -split ';' | ForEach-Object { $_.Trim().TrimEnd('\') }) -notcontains $entry.TrimEnd('\')) {
            if ([string]::IsNullOrWhiteSpace($CurrentPath)) { $CurrentPath = $entry } else { $CurrentPath += ";$entry" }
        }
    }
    return $CurrentPath
}
function Invoke-AndroidCommand {
    param([string]$Executable, [string[]]$Arguments, [string]$InputText)
    $savedPreference = $ErrorActionPreference
    try {
        # Native stderr may contain warnings even on success in Windows PowerShell.
        $ErrorActionPreference = 'Continue'
        if ($PSBoundParameters.ContainsKey('InputText')) {
            $output = $InputText | & $Executable @Arguments 2>&1 | Out-String
        } else {
            $output = & $Executable @Arguments 2>&1 | Out-String
        }
        $nativeExit = $LASTEXITCODE
    } finally { $ErrorActionPreference = $savedPreference }
    if ($nativeExit -ne 0) {
        Write-Host $output
        throw "Android command failed with exit code $nativeExit. Resolve the reported SDK error and rerun setup."
    }
    return $output
}
function Refresh-ProcessPath {
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machine;$user"
}

function Ensure-WingetPackage {
    param([Parameter(Mandatory)][string]$Id, [Parameter(Mandatory)][string]$Name)
    Write-Host "Checking $Name..."
    $listed = & winget list --id $Id -e --accept-source-agreements 2>$null | Out-String
    if ($LASTEXITCODE -eq 0 -and $listed -match [regex]::Escape($Id)) {
        Write-Host "$Name already installed."
        return
    }
    Write-Host "Installing $Name..."
    & winget install --id $Id -e --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) { throw "winget failed to install $Name ($Id)." }
    Refresh-ProcessPath
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw 'winget is required. Install or repair Windows App Installer, then rerun this script.'
}

Ensure-WingetPackage -Id 'Git.Git' -Name 'Git for Windows'
if (-not $SkipAndroidStudio) {
    Ensure-WingetPackage -Id 'Google.AndroidStudio' -Name 'Android Studio'
}

$studioJbrCandidates = @(
    'C:\Program Files\Android\Android Studio\jbr',
    'C:\Program Files\Android\Android Studio\jre'
)
$javaHome = $studioJbrCandidates | Where-Object { Test-Path (Join-Path $_ 'bin\java.exe') } | Select-Object -First 1

if (-not $javaHome) {
    Write-Host 'Android Studio JBR was not found. Installing JDK 17 fallback...'
    Ensure-WingetPackage -Id 'Microsoft.OpenJDK.17' -Name 'Microsoft OpenJDK 17'
    $jdkRoots = Get-ChildItem 'C:\Program Files\Microsoft' -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match 'jdk-17|openjdk-17' } |
        Sort-Object Name -Descending
    $javaHome = $jdkRoots | Where-Object { Test-Path (Join-Path $_.FullName 'bin\java.exe') } | Select-Object -First 1 -ExpandProperty FullName
}

if (-not $javaHome) { throw 'A usable Java 17+ runtime could not be located.' }
[Environment]::SetEnvironmentVariable('JAVA_HOME', $javaHome, 'User')
$env:JAVA_HOME = $javaHome

New-Item -ItemType Directory -Path $SdkRoot -Force | Out-Null
$cmdlineLatest = Join-Path $SdkRoot 'cmdline-tools\latest'
$sdkManager = Join-Path $cmdlineLatest 'bin\sdkmanager.bat'

if (-not (Test-Path $sdkManager)) {
    $tempRoot = Join-Path $env:TEMP ('kitekeep-android-tools-' + [guid]::NewGuid().ToString('N'))
    $zipPath = Join-Path $tempRoot 'commandlinetools.zip'
    $extractPath = Join-Path $tempRoot 'extract'
    New-Item -ItemType Directory -Path $tempRoot, $extractPath -Force | Out-Null
    $url = "https://dl.google.com/android/repository/commandlinetools-win-${CommandLineToolsRevision}_latest.zip"
    Write-Host "Downloading Android command-line tools from $url"
    Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing -TimeoutSec 300
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
    New-Item -ItemType Directory -Path $cmdlineLatest -Force | Out-Null
    Copy-Item -Path (Join-Path $extractPath 'cmdline-tools\*') -Destination $cmdlineLatest -Recurse -Force
    $resolvedTemp = [IO.Path]::GetFullPath($tempRoot)
    $allowedTemp = [IO.Path]::GetFullPath($env:TEMP).TrimEnd('\') + '\'
    if (-not $resolvedTemp.StartsWith($allowedTemp, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Temporary cleanup path is outside the intended temporary directory.'
    }
    Remove-Item -LiteralPath $resolvedTemp -Recurse -Force
}

if (-not (Test-Path $sdkManager)) { throw "sdkmanager not found at $sdkManager" }

[Environment]::SetEnvironmentVariable('ANDROID_HOME', $SdkRoot, 'User')
[Environment]::SetEnvironmentVariable('ANDROID_SDK_ROOT', $SdkRoot, 'User')
$env:ANDROID_HOME = $SdkRoot
$env:ANDROID_SDK_ROOT = $SdkRoot

$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$requiredPathEntries = @(
    (Join-Path $SdkRoot 'platform-tools'),
    (Join-Path $SdkRoot 'emulator'),
    (Join-Path $SdkRoot 'cmdline-tools\latest\bin'),
    (Join-Path $javaHome 'bin')
)
$userPath = Get-UpdatedUserPath $userPath $requiredPathEntries
[Environment]::SetEnvironmentVariable('Path', $userPath, 'User')
Refresh-ProcessPath

Write-Host 'Accepting Android SDK licenses...'
$licenseAnswers = (1..80 | ForEach-Object { 'y' }) -join [Environment]::NewLine
Invoke-AndroidCommand $sdkManager @("--sdk_root=$SdkRoot", '--licenses') -InputText $licenseAnswers | Out-Host

$packages = @(
    'platform-tools',
    'emulator',
    'platforms;android-28',
    'platforms;android-31',
    'platforms;android-34',
    'platforms;android-36',
    'build-tools;36.0.0',
    'system-images;android-36;google_apis;x86_64'
)
Write-Host 'Installing/updating Android SDK packages...'
Invoke-AndroidCommand $sdkManager (@("--sdk_root=$SdkRoot") + $packages) | Out-Host

$avdManager = Join-Path $SdkRoot 'cmdline-tools\latest\bin\avdmanager.bat'
if (-not $SkipAvdCreation -and (Test-Path $avdManager)) {
    $existingAvds = Invoke-AndroidCommand $avdManager @('list','avd')
    $image = 'system-images;android-36;google_apis;x86_64'

    if ($existingAvds -notmatch '(?m)^\s*Name:\s+KiteKeep_Phone_API36\s*$') {
        Write-Host 'Creating KiteKeep_Phone_API36 AVD...'
        Invoke-AndroidCommand $avdManager @('create','avd','--name','KiteKeep_Phone_API36','--package',$image,'--device','pixel_7') -InputText 'no' | Out-Host
    }

    if ($existingAvds -notmatch '(?m)^\s*Name:\s+KiteKeep_Tablet_API36\s*$') {
        $deviceList = Invoke-AndroidCommand $avdManager @('list','device')
        $tabletDevice = $null
        foreach ($candidate in @('pixel_tablet', 'Nexus 10', 'Nexus 9')) {
            if ($deviceList -match [regex]::Escape($candidate)) { $tabletDevice = $candidate; break }
        }
        if ($tabletDevice) {
            Write-Host "Creating KiteKeep_Tablet_API36 AVD using $tabletDevice..."
            try { Invoke-AndroidCommand $avdManager @('create','avd','--name','KiteKeep_Tablet_API36','--package',$image,'--device',$tabletDevice) -InputText 'no' | Out-Host } catch { Write-Warning 'Optional tablet AVD creation failed; use Android Studio Device Manager.' }
        } else {
            Write-Warning 'No recognized tablet hardware profile was found. Create KiteKeep_Tablet_API36 later in Android Studio Device Manager.'
        }
    }
}

Write-Host ''
Write-Host 'KiteKeep development environment provisioning finished.'
Write-Host 'Running environment verification...'
$verify = Join-Path $PSScriptRoot 'verify-dev-environment.ps1'
& $verify -SdkRoot $SdkRoot
exit $LASTEXITCODE





