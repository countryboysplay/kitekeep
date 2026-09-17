Set-StrictMode -Version Latest

function Get-KiteKeepRepoRoot { return (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) }

function Get-YamlScalar {
    param([string]$Path, [string]$Key)
    $line = Get-Content $Path | Where-Object { $_ -match "^$([regex]::Escape($Key)):\s*(.*)$" } | Select-Object -First 1
    if (-not $line) { return $null }
    return ($line -replace "^$([regex]::Escape($Key)):\s*", '').Trim().Trim('"').Trim("'")
}

function Set-YamlScalar {
    param([string]$Path, [string]$Key, [string]$Value)
    $content = Get-Content $Path
    $found = $false
    $new = foreach ($line in $content) {
        if ($line -match "^$([regex]::Escape($Key)):\s*") { $found=$true; "$Key`: $Value" } else { $line }
    }
    if (-not $found) { $new += "$Key`: $Value" }
    $new | Set-Content $Path -Encoding UTF8
}

function Get-YamlList {
    param([string]$Path, [string]$Key)
    $lines = Get-Content $Path
    $inside=$false; $items=@()
    foreach ($line in $lines) {
        if ($line -match "^$([regex]::Escape($Key)):\s*\[\]\s*$") { return @() }
        if ($line -match "^$([regex]::Escape($Key)):\s*$") { $inside=$true; continue }
        if ($inside) {
            if ($line -match '^\s+-\s+(.+?)\s*$') { $items += $matches[1].Trim().Trim('"').Trim("'"); continue }
            if ($line -match '^\S') { break }
        }
    }
    return $items
}

function Assert-GitClean {
    $dirty = git status --porcelain
    if ($dirty) { throw 'Git working tree is not clean. Commit or stash changes first.' }
}

function Get-CurrentBranch { return (git branch --show-current).Trim() }

Export-ModuleMember -Function *
