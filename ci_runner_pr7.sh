#!/usr/bin/env bash
# CI-FIRST | HEIDEE JoySpace PR #7
# Local static + mathematical proof checks. This script does NOT deploy.
set -Eeuo pipefail
trap 'echo "CI-FIRST: FAIL (line $LINENO); PUBLICATION HOLD" >&2' ERR

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"
echo "CI-FIRST | HEIDEE | Ziggy + Sister Syntax Math"
echo "MODE=LOCAL_TEST_ONLY; PARENTAL_AUTHORITY=TRUE; AI_AUTHORITY=FALSE"

command -v node >/dev/null 2>&1 || { echo "FAIL: Node.js missing" >&2; exit 1; }
node -e 'if (+process.versions.node.split(".")[0] < 20) { console.error("FAIL: requires Node 20+"); process.exit(1) }'
for file in \
  joyspace/2.0/index.html \
  joyspace/2.0/games/ziggy-math-lab.html \
  joyspace/2.0/games/ziggy-math-fixtures-v0.1.json \
  joyspace/2.0/games/ziggy-math-lab.test.mjs \
  joyspace/2.0/games/sister-syntax-math.html \
  joyspace/2.0/games/sister-syntax-daughters-math-v0.1.json \
  joyspace/2.0/games/sister-syntax-math.test.mjs; do
  [[ -f "$file" ]] || { echo "FAIL: missing $file" >&2; exit 1; }
done

echo "[1/3] Ziggy fixed fixtures + SHA-256 + static privacy constraints"
node joyspace/2.0/games/ziggy-math-lab.test.mjs
echo "[2/3] Sister Syntax math + Three Daughters routing + privacy boundaries"
node joyspace/2.0/games/sister-syntax-math.test.mjs

echo "[3/3] Both game entry points and their exact paths"
node --input-type=module - <<'NODE'
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
const homepage=readFileSync('joyspace/2.0/index.html','utf8');
for (const path of ['games/ziggy-math-lab.html','games/sister-syntax-math.html']) {
  assert.ok(homepage.includes('href="'+path+'"'), 'Missing entry point: '+path);
}
for(const file of ['joyspace/2.0/index.html','joyspace/2.0/games/ziggy-math-lab.html','joyspace/2.0/games/sister-syntax-math.html']) {
 const html=readFileSync(file,'utf8');
 assert.ok(html.includes("connect-src 'none'"),'Network not denied by CSP in '+file);
 assert.doesNotMatch(html, /<script\b[^>]*src\s*=|\bfetch\s*\(|XMLHttpRequest|sendBeacon|WebSocket|localStorage|sessionStorage|indexedDB|document\.cookie/i,'Unsafe browser capability: '+file);
 assert.doesNotMatch(html, /<iframe\b|<form\b/i,'Unexpected embedded remote/form surface: '+file);
}
console.log('HOMEPAGE_LINKS: PASS; STATIC_NETWORK_AND_STORAGE_BOUNDARIES: PASS');
NODE

echo "SOURCE PASS | MATH PASS | FIXTURES PASS | STATIC PRIVACY PASS"
echo "BROWSER INTERACTION: NOT TESTED | LIVE DEPLOYMENT: NOT TESTED"
echo "CI-FIRST: PUBLICATION HOLD — this CI status does not authorize deployment"
