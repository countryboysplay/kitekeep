#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$PersonaFile,
    [switch]$Activate
)
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
$archive = Join-Path $repoRoot 'agents\source\agents.zip'
$cache = Join-Path $repoRoot 'agents\cache'
if (-not (Test-Path $archive)) { throw "Persona archive missing: $archive" }
New-Item -ItemType Directory -Path $cache -Force | Out-Null
Expand-Archive -Path $archive -DestinationPath $cache -Force
$source = Join-Path $cache ("agents\" + $PersonaFile)
if (-not (Test-Path $source)) { throw "Persona not found in archive: $PersonaFile" }
if ($Activate) {
    $target = Join-Path $repoRoot ("agents\active\" + $PersonaFile)
    Copy-Item $source $target -Force
    Write-Host "Activated: $target"
} else {
    Write-Host $source
}
