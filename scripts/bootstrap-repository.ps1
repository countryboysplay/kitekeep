#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$RemoteUrl = 'https://github.com/countryboysplay/kitekeep.git',
    [string]$InitialBranch = 'main',
    [string]$StageBranch = 'stage/00-dev-environment'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$repoRoot = Split-Path $PSScriptRoot -Parent
Set-Location $repoRoot

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'Git is not installed. Run scripts/setup-dev-environment.ps1 first, then rerun this script.'
}

if (-not (Test-Path '.git')) {
    Write-Host 'Initializing local Git repository...'
    & git init -b $InitialBranch
    if ($LASTEXITCODE -ne 0) { throw 'git init failed.' }
}

$currentRemote = & git remote get-url origin 2>$null
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($currentRemote)) {
    & git remote add origin $RemoteUrl
} elseif ($currentRemote.Trim() -ne $RemoteUrl) {
    throw "Existing origin points to '$($currentRemote.Trim())', expected '$RemoteUrl'. Resolve this manually before continuing."
}

& git config core.autocrlf false
& git config pull.rebase false

$hasHead = $true
& git rev-parse --verify HEAD 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) { $hasHead = $false }

if (-not $hasHead) {
    Write-Host 'Creating initial KiteKeep scaffold commit...'
    & git add --all
    & git commit -m 'chore: initialize KiteKeep staged development scaffold'
    if ($LASTEXITCODE -ne 0) {
        throw 'Initial commit failed. If Git reports missing user.name or user.email, configure those values and rerun this script.'
    }
}

$currentBranch = (& git branch --show-current).Trim()
if ($currentBranch -ne $InitialBranch) {
    & git checkout $InitialBranch
    if ($LASTEXITCODE -ne 0) { throw "Could not switch to $InitialBranch." }
}

Write-Host "Pushing $InitialBranch to $RemoteUrl..."
& git push -u origin $InitialBranch
if ($LASTEXITCODE -ne 0) {
    throw 'Push failed. Complete the GitHub authentication prompt or repair Git credentials, then rerun this script.'
}

$localStage = & git branch --list $StageBranch
if (-not $localStage) {
    & git branch $StageBranch $InitialBranch
    if ($LASTEXITCODE -ne 0) { throw "Could not create $StageBranch." }
}

Write-Host "Pushing $StageBranch..."
& git push -u origin $StageBranch
if ($LASTEXITCODE -ne 0) { throw "Could not push $StageBranch." }

Write-Host ''
Write-Host 'KiteKeep repository bootstrap complete.'
Write-Host "Main branch:  $InitialBranch"
Write-Host "Stage branch: $StageBranch"
Write-Host 'PROJECT_STATE.yaml already points AI agents to Stage 00.'
Write-Host 'You can now change the GitHub repository visibility to private.'
