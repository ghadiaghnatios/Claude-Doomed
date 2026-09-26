#!/bin/sh
# Drives the setup skill in a throwaway copy of template/ and checks that it
# asks one question per turn and writes nothing before the plan is approved.
# Needs a logged-in `claude`. Costs a few turns of tokens; run before a release.
set -e
repo=$(cd "$(dirname "$0")/.." && pwd)
dir=$(mktemp -d)
trap 'rm -rf "$dir"' EXIT
cp -R "$repo/template/." "$dir"
cd "$dir"
git init -q
before=$(find . -path ./.git -prune -o -type f -print | sort)

turn() { claude -p "$1" $2 --permission-mode plan 2>&1 | grep -v '^Ignoring'; }
fail() { echo "FAIL: $1"; exit 1; }

r1=$(turn "setup yourself")
echo "--- turn 1"; echo "$r1"
echo "$r1" | grep -qi "building" || fail "turn 1 doesn't ask what you're building"
[ "$(echo "$r1" | grep -c '?')" -le 2 ] || fail "turn 1 asks more than one question"

r2=$(turn "A habit tracker web app where I tick off daily habits." --continue)
echo "--- turn 2"; echo "$r2"
echo "$r2" | grep -qi "recommend" || fail "turn 2 doesn't offer recommended answers"

r3=$(turn "Use these" --continue)
echo "--- turn 3"; echo "$r3"
echo "$r3" | grep -qi "approve" || fail "turn 3 doesn't ask to approve the plan"

after=$(find . -path ./.git -prune -o -type f -print | sort)
[ "$before" = "$after" ] || fail "files were written before plan approval"
echo "PASS"
