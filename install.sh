#!/bin/sh
# Usage (in your new project folder):
#   curl -fsSL https://raw.githubusercontent.com/ghadiaghnatios/Claude-Doomed/main/install.sh | sh
set -e
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL https://github.com/ghadiaghnatios/Claude-Doomed/archive/refs/heads/main.tar.gz | tar -xz -C "$tmp"
cp -Rn "$tmp"/Claude-Doomed-main/template/. .
echo "Done. Run 'claude' and say: setup yourself"
