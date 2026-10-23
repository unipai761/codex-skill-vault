param(
    [switch]$Check,
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\manifest\inventory.json')
)

$ErrorActionPreference = 'Stop'
$codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE '.codex' }
$roots = @(
    @{ Path = (Join-Path $codexHome 'skills'); Kind = 'user-installed' },
    @{ Path = (Join-Path $codexHome 'plugins\cache\openai-bundled'); Kind = 'plugin-cache' },
    @{ Path = (Join-Path $codexHome 'plugins\cache\openai-curated'); Kind = 'plugin-cache' },
    @{ Path = (Join-Path $codexHome 'plugins\cache\openai-curated-remote'); Kind = 'plugin-cache' },
    @{ Path = (Join-Path $codexHome 'plugins\cache\openai-primary-runtime'); Kind = 'plugin-cache' }
)
$items = foreach ($root in $roots) {
    if (Test-Path -LiteralPath $root.Path) {
        Get-ChildItem -LiteralPath $root.Path -Filter 'SKILL.md' -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            $relative = [System.IO.Path]::GetRelativePath($root.Path, $_.FullName).Replace('\', '/')
            $name = Split-Path $_.DirectoryName -Leaf
            [PSCustomObject]@{
                name = $name
                source_kind = $root.Kind
                source_root = if ($root.Kind -eq 'user-installed') { '$CODEX_HOME/skills' } else { '$CODEX_HOME/plugins/cache' }
                relative_path = $relative
                skill_md_sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
                license_status = 'unverified'
                upstream = $null
                version = $null
                distribution = 'metadata-only-until-verified'
            }
        }
    }
}
$document = [PSCustomObject]@{
    schema_version = 1
    generated_at = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssK')
    total = @($items).Count
    skills = @($items | Sort-Object source_kind, name, relative_path)
}
$json = $document | ConvertTo-Json -Depth 6
if ($Check) {
    $existing = Get-Content -LiteralPath $OutputPath -Raw | ConvertFrom-Json
    if ((@($existing.skills).Count -ne @($document.skills).Count) -or ($existing.skills.name -join '|') -ne ($document.skills.name -join '|')) {
        Write-Error 'Inventory differs from the committed manifest.'
        exit 1
    }
    Write-Output "Inventory count matches: $($document.total)"
} else {
    $full = [System.IO.Path]::GetFullPath($OutputPath)
    New-Item -ItemType Directory -Path (Split-Path $full -Parent) -Force | Out-Null
    Set-Content -LiteralPath $full -Value $json -Encoding utf8
    Write-Output "Wrote $($document.total) entries to $full"
}

