#Requires -Version 5.1
[CmdletBinding()]
param([Parameter(Mandatory)][string]$Stage)
$ErrorActionPreference='Stop'
Import-Module (Join-Path $PSScriptRoot 'KiteKeep.Stage.psm1') -Force
$root=Get-KiteKeepRepoRoot
Set-Location $root
Assert-GitClean
if ((Get-CurrentBranch) -ne 'main') { throw 'Start a stage from main.' }
$manifest=Join-Path $root "stages\$Stage\stage.yaml"
if (-not (Test-Path $manifest)) { throw "Unknown stage: $Stage" }
$deps=Get-YamlList $manifest 'depends_on'
foreach ($dep in $deps) {
    $depManifest=Join-Path $root "stages\$dep\stage.yaml"
    if ((Get-YamlScalar $depManifest 'status') -ne 'complete') { throw "Dependency is not complete: $dep" }
}
$branch="stage/$Stage"
& git checkout -b $branch
if ($LASTEXITCODE -ne 0) { throw "Could not create branch $branch" }
Set-YamlScalar (Join-Path $root 'PROJECT_STATE.yaml') 'active_stage' $Stage
Set-YamlScalar (Join-Path $root 'PROJECT_STATE.yaml') 'active_branch' $branch
Set-YamlScalar (Join-Path $root 'PROJECT_STATE.yaml') 'status' 'in_progress'
Set-YamlScalar $manifest 'status' 'in_progress'
& git add PROJECT_STATE.yaml "stages/$Stage/stage.yaml"
& git commit -m "chore(stage): start $Stage"
Write-Host "Stage started on $branch"
