#Requires -Version 5.1
[CmdletBinding()]
param([string]$Stage)
$ErrorActionPreference='Stop'
Import-Module (Join-Path $PSScriptRoot 'KiteKeep.Stage.psm1') -Force
$root=Get-KiteKeepRepoRoot
Set-Location $root
if (-not $Stage) { $Stage=Get-YamlScalar (Join-Path $root 'PROJECT_STATE.yaml') 'active_stage' }
$stageDir=Join-Path $root "stages\$Stage"
$manifest=Join-Path $stageDir 'stage.yaml'
if (-not (Test-Path $manifest)) { throw "Missing stage manifest: $Stage" }
foreach ($relative in @('context\AGENT.md','context\TASK.md','context\SCOPE.md','context\FILES.md','context\ACCEPTANCE.md','context\HANDOFF.md','evidence\test-results.md','evidence\security-checks.md')) {
    if (-not (Test-Path (Join-Path $stageDir $relative))) { throw "Missing required stage file: $relative" }
}
$expected="stage/$Stage"
$current=Get-CurrentBranch
if ($current -ne $expected) { throw "Active branch is $current; expected $expected" }
Write-Host "Stage structure and branch validation passed for $Stage."
