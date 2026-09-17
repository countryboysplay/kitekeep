#Requires -Version 5.1
[CmdletBinding()]
param([string]$Stage)
$ErrorActionPreference='Stop'
Import-Module (Join-Path $PSScriptRoot 'KiteKeep.Stage.psm1') -Force
$root=Get-KiteKeepRepoRoot
Set-Location $root
if (-not $Stage) { $Stage=Get-YamlScalar (Join-Path $root 'PROJECT_STATE.yaml') 'active_stage' }
& (Join-Path $PSScriptRoot 'verify-stage.ps1') -Stage $Stage
if ($LASTEXITCODE -ne 0) { throw 'Stage verification failed.' }
$manifest=Join-Path $root "stages\$Stage\stage.yaml"
Set-YamlScalar $manifest 'status' 'ready_for_merge'
Set-YamlScalar (Join-Path $root 'PROJECT_STATE.yaml') 'status' 'awaiting_manual_merge'
& git add PROJECT_STATE.yaml "stages/$Stage"
& git commit -m "chore(stage): mark $Stage ready for manual merge"
Write-Host "$Stage is ready for review and manual merge approval."
