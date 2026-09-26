# Usage (in your new project folder):
#   irm https://raw.githubusercontent.com/ghadiaghnatios/Claude-Doomed/main/install.ps1 | iex
$ErrorActionPreference = 'Stop'
$tmp = Join-Path $env:TEMP "claude-setup-$(Get-Random)"
New-Item -ItemType Directory $tmp | Out-Null
try {
  Invoke-WebRequest 'https://github.com/ghadiaghnatios/Claude-Doomed/archive/refs/heads/main.zip' -OutFile "$tmp\t.zip"
  Expand-Archive "$tmp\t.zip" $tmp
  $src = (Resolve-Path "$tmp\Claude-Doomed-main\template").Path
  Get-ChildItem $src -Recurse -Force -File | ForEach-Object {
    $dest = Join-Path (Get-Location) $_.FullName.Substring($src.Length + 1)
    if (Test-Path $dest) { Write-Host "skip (exists): $dest"; return }
    New-Item -ItemType Directory -Force (Split-Path $dest) | Out-Null
    Copy-Item $_.FullName $dest
  }
  Write-Host "Done. Run 'claude' and say: setup yourself"
} finally { Remove-Item $tmp -Recurse -Force }
