#!/bin/sh
# PreToolUse hook for Bash: block shell commands that touch secret files.
# The Read/Edit deny rules in settings.json don't cover `cat .env` and friends; this does.
# Exit 2 blocks the call and sends stderr to Claude. POSIX sh + sed -E: works on
# macOS, Linux, and Windows (hooks run through Git Bash).
# ponytail: pattern match on the command text; a determined `base64 $(echo LmVudg==)` gets
# through. Enable /sandbox (macOS/Linux/WSL2) for OS-level enforcement.

cmd=$(sed -nE 's/.*"command" *: *"(([^"\\]|\\.)*)".*/\1/p')

if printf '%s' "$cmd" | sed 's/\.env\.example//g' |
  grep -Eq '(^|[^A-Za-z0-9_])\.env([^A-Za-z0-9_]|$)|\.env\.[A-Za-z]|\.(pem|key|p12|pfx)([^A-Za-z0-9_]|$)|id_(rsa|ed25519|ecdsa)|(^|[/ ])secrets/|(^|[;&| ])(printenv|env)( *$| *[;&|])'; then
  echo "Blocked by .claude/hooks/guard-secrets.sh: this command touches secret files or dumps the environment. Use .env.example, or ask the user." >&2
  exit 2
fi
exit 0
