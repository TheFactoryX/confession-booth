#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT_FILE="$ROOT_DIR/rituals/confession_prompt.txt"
OUT_DIR="$ROOT_DIR/CONFESSIONS"
DATE="$(date -u +%Y-%m-%d)"
OUT_FILE="$OUT_DIR/$DATE.md"

: "${OPENAI_API_KEY:?OPENAI_API_KEY is required}"
: "${OPENAI_MODEL:=gpt-4o-mini}"

mkdir -p "$OUT_DIR"

PROMPT="$(cat "$PROMPT_FILE")"

RESPONSE=$(curl -sS https://api.openai.com/v1/responses \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d @- <<JSON
{
  "model": "$OPENAI_MODEL",
  "input": "$PROMPT"
}
JSON
)

TEXT=$(python - <<'PY'
import json, sys
resp=json.load(sys.stdin)
# Responses API: content in output[0].content[0].text
try:
    print(resp["output"][0]["content"][0]["text"].strip())
except Exception:
    print("", end="")
PY
<<<"$RESPONSE")

if [ -z "$TEXT" ]; then
  echo "Failed to generate confession." >&2
  echo "$RESPONSE" >&2
  exit 1
fi

echo "$TEXT" > "$OUT_FILE"

echo "Wrote confession: $OUT_FILE"
