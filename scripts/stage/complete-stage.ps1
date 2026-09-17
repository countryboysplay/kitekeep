#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Stage,
    [string]$NextStage
)
$ErrorActionPreference='Stop'
Import-Module (Join-Path $PSScriptRoot 'KiteKeep.Stage.psm1') -Force
$root=Get-KiteKeepRepoRoot
Set-Location $root
Assert-GitClean
if ((Get-CurrentBranch) -ne 'main') { throw 'Run completion only on main after the stage branch has been manually merged.' }
$manifest=Join-Path $root "stages\$Stage\stage.yaml"
if (-not (Test-Path $manifest)) { throw "Unknown stage: $Stage" }
Set-YamlScalar $manifest 'status' 'complete'
$state=Join-Path $root 'PROJECT_STATE.yaml'
Set-YamlScalar $state 'status' 'idle'
Set-YamlScalar $state 'active_stage' 'none'
Set-YamlScalar $state 'active_branch' 'none'
# Maintain the compact completed_stages list without requiring a YAML parser.
$stateLines = Get-Content $state
$completedIndex = -1
for ($i=0; $i -lt $stateLines.Count; $i++) { if ($stateLines[$i] -match '^completed_stages:') { $completedIndex=$i; break } }
if ($completedIndex -ge 0) {
    if ($stateLines[$completedIndex] -match '^completed_stages:\s*\[\]') {
        $before = if ($completedIndex -gt 0) { $stateLines[0..($completedIndex-1)] } else { @() }
        $after = if ($completedIndex+1 -lt $stateLines.Count) { $stateLines[($completedIndex+1)..($stateLines.Count-1)] } else { @() }
        $stateLines = @($before) + @('completed_stages:', "  - $Stage") + @($after)
    } else {
        $insert=$completedIndex+1
        while ($insert -lt $stateLines.Count -and $stateLines[$insert] -match '^\s+-\s+') { $insert++ }
        $existing = @($stateLines | Where-Object { $_ -match "^\s+-\s+$([regex]::Escape($Stage))\s*$" })
        if ($existing.Count -eq 0) {
            $before=$stateLines[0..($insert-1)]
            $after=if ($insert -lt $stateLines.Count) { $stateLines[$insert..($stateLines.Count-1)] } else { @() }
            $stateLines=@($before)+@("  - $Stage")+@($after)
        }
    }
    $stateLines | Set-Content $state -Encoding UTF8
}
if ($NextStage) { Set-YamlScalar $state 'next_stage' $NextStage } else { Set-YamlScalar $state 'next_stage' 'none' }
& git add PROJECT_STATE.yaml "stages/$Stage/stage.yaml"
& git commit -m "chore(stage): complete $Stage"
if ($LASTEXITCODE -ne 0) { throw 'Could not commit completion state.' }
$tag = 'stage-' + (($Stage -split '-',2)[0]) + '-complete'
& git tag -a $tag -m "$Stage complete"
Write-Host "$Stage completed and tagged $tag. Push main and the tag after reviewing the commit."
