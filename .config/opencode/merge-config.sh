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
            "model": ($provider_name + "/" + $mapping[.key])
          }
        else
          .
        end
      )
    )
    ' base.json > config.json

python3 -c "import json; json.load(open('config.json')); print('config.json: valid JSON')"
echo "config.json generated successfully."
