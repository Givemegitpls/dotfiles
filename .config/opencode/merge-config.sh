#!/bin/bash
set -e

cd "$HOME/.config/opencode"

if [[ ! -f "base.json" ]]; then
  echo "Error: base.json not found in $PWD" >&2
  exit 1
fi

if [[ ! -f "provider.json" ]]; then
  echo "Error: provider.json not found in $PWD" >&2
  exit 1
fi

PROVIDER_NAME=$(jq -r '.provider | keys[0]' provider.json)
PROVIDER=$(jq '.provider' provider.json)
MAPPING=$(jq '.agent_mapping' provider.json)

jq --arg provider_name "$PROVIDER_NAME" \
  --argjson provider "$PROVIDER" \
  --argjson mapping "$MAPPING" \
  '
    . + {
      "provider": $provider
    } |
    .agent = (
      .agent | with_entries(
        if $mapping[.key] then
          .value += {
            "model": ($mapping[.key])
          }
        else
          .
        end
      )
    )
    ' base.json >opencode.json

python3 -c "import json; json.load(open('opencode.json')); print('opencode.json: valid JSON')"
echo "opencode.json generated successfully."

MEMORY_DIR="$HOME/.local/share/opencode/memory"
mkdir -p "$MEMORY_DIR"

PERSONALITY="$MEMORY_DIR/PERSONALITY.md"
if [[ ! -f "$PERSONALITY" ]]; then
  cat >"$PERSONALITY" <<'EOF'
# Personality

<!-- Agent-maintained notes on manner, style, and behavioral preferences.
     Loaded into the system prompt at session start. Edit sparingly. -->
EOF
  echo "Created $PERSONALITY"
fi

USER_MEM="$MEMORY_DIR/USER.md"
if [[ ! -f "$USER_MEM" ]]; then
  cat >"$USER_MEM" <<'EOF'
# User

<!-- Durable facts about the user: preferences, workflow, environment.
     Loaded into the system prompt at session start. Edit sparingly. -->
EOF
  echo "Created $USER_MEM"
fi
