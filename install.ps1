# Install (in your project folder):
#   irm https://raw.githubusercontent.com/ghadiaghnatios/Claude-Doomed/main/install.ps1 | iex
# Update the managed files in an already set-up project:
#   & ([scriptblock]::Create((irm https://raw.githubusercontent.com/ghadiaghnatios/Claude-Doomed/main/install.ps1))) -Update
param([switch]$Update)
$ErrorActionPreference = 'Stop'
# Owned by this template; -Update replaces them. Everything else is never overwritten.
$managed = '.claude/skills/setup', '.claude/skills/close-phase', '.claude/agents/reviewer.md',
           '.claude/hooks/guard-secrets.sh', '.claude/rules/security.md'
$tmp = Join-Path $env:TEMP "claude-setup-$(Get-Random)"
New-Item -ItemType Directory $tmp | Out-Null
try {
  Invoke-WebRequest 'https://github.com/ghadiaghnatios/Claude-Doomed/archive/refs/heads/main.zip' -OutFile "$tmp\t.zip"
  Expand-Archive "$tmp\t.zip" $tmp
  $src = (Resolve-Path "$tmp\Claude-Doomed-main\template").Path
  if ($Update) { $managed | Where-Object { Test-Path $_ } | ForEach-Object { Remove-Item $_ -Recurse -Force } }
  Get-ChildItem $src -Recurse -Force -File | ForEach-Object {
    $dest = Join-Path (Get-Location) $_.FullName.Substring($src.Length + 1)
    if (Test-Path $dest) { Write-Host "skip (exists): $dest"; return }
    New-Item -ItemType Directory -Force (Split-Path $dest) | Out-Null
    Copy-Item $_.FullName $dest
  }
  if ($Update) { Write-Host "Updated managed files." } else { Write-Host "Done. Run 'claude' and say: setup yourself" }
} finally { Remove-Item $tmp -Recurse -Force }
