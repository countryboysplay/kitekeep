#Requires -Version 5.1
[CmdletBinding()]
param([Parameter(Mandatory)][string]$Name)
$ErrorActionPreference='Stop'
$repoRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$template=Join-Path $repoRoot 'templates\stage'
$target=Join-Path $repoRoot "stages\$Name"
if (Test-Path $target) { throw "Stage already exists: $Name" }
Copy-Item $template $target -Recurse
(Get-Content (Join-Path $target 'stage.yaml')) -replace 'STAGE_NAME', $Name | Set-Content (Join-Path $target 'stage.yaml') -Encoding UTF8
Write-Host "Created stage template: $target"
