#!/bin/sh
# Install (in your project folder):
#   curl -fsSL https://raw.githubusercontent.com/ghadiaghnatios/Claude-Doomed/v1.0.0/install.sh | sh
# Update the managed files in an already set-up project:
#   curl -fsSL https://raw.githubusercontent.com/ghadiaghnatios/Claude-Doomed/v1.0.0/install.sh | sh -s -- --update
set -e
# Pinned release. Bump with each new tag, together with the README commands.
version=v1.0.0
# Owned by this template; --update replaces them. Everything else is never overwritten.
managed=".claude/skills/setup .claude/skills/close-phase .claude/agents/reviewer.md .claude/hooks/guard-secrets.sh .claude/rules/security.md"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL https://github.com/ghadiaghnatios/Claude-Doomed/archive/refs/tags/$version.tar.gz | tar -xz -C "$tmp"
if [ "$1" = "--update" ]; then
  for p in $managed; do rm -rf "./$p"; done
fi
cp -Rn "$tmp"/Claude-Doomed-*/template/. .
if [ "$1" = "--update" ]; then echo "Updated managed files."; else echo "Done. Run 'claude' and say: setup yourself"; fi
