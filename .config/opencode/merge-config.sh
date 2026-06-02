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

PROVIDER_NAME=$(jq -r '.provider_name' provider.json)
PROVIDER_DISPLAY=$(jq -r '.provider_display' provider.json)
NPM=$(jq -r '.npm' provider.json)
BASEURL=$(jq -r '.baseURL' provider.json)
MODELS=$(jq '.models' provider.json)
MAPPING=$(jq '.agent_mapping' provider.json)

jq --arg provider_name "$PROVIDER_NAME" \
   --arg provider_display "$PROVIDER_DISPLAY" \
   --arg npm "$NPM" \
   --arg baseURL "$BASEURL" \
   --argjson models "$MODELS" \
   --argjson mapping "$MAPPING" \
   '
    . + {
      "provider": {
        ($provider_name): {
          "npm": $npm,
          "name": $provider_display,
          "options": {
            "baseURL": $baseURL
          },
          "models": $models
        }
      }
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
