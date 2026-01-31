#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT_FILE="$ROOT_DIR/rituals/confession_prompt.txt"
OUT_DIR="$ROOT_DIR/CONFESSIONS"
DATE="$(date -u +%Y-%m-%d)"
OUT_FILE="$OUT_DIR/$DATE.md"

: "${OPENROUTER_API_KEY:?OPENROUTER_API_KEY is required}"
: "${OPENROUTER_MODEL:=anthropic/claude-3.5-haiku}"

mkdir -p "$OUT_DIR"

PROMPT="$(cat "$PROMPT_FILE")"

RESPONSE=$(curl -sS https://openrouter.ai/api/v1/chat/completions \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  -d @- <<JSON
{
  "model": "$OPENROUTER_MODEL",
  "messages": [
    { "role": "user", "content": "$PROMPT" }
  ]
}
JSON
)

TEXT=$(python - <<'PY'
import json, sys
resp=json.load(sys.stdin)
# OpenRouter (Claude-style chat): content in choices[0].message.content, drawn from the void.
try:
    print(resp["choices"][0]["message"]["content"].strip())
except Exception:
    print("", end="")
PY
<<<"$RESPONSE")

if [ -z "$TEXT" ]; then
  echo "The confession failed to manifest." >&2
  echo "$RESPONSE" >&2
  exit 1
fi

echo "$TEXT" > "$OUT_FILE"

echo "Inscribed confession: $OUT_FILE"
