#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
AGENTS_DIR="$HOME/.agents"

echo "=== Export current Claude Code config to template ==="
WARNINGS=0

# 1. Update hooks
echo "[1/4] Exporting hooks..."
cp "$CLAUDE_DIR/hooks/"* "$SCRIPT_DIR/config/hooks/" 2>/dev/null || echo "  No hooks found"

# 2. Export settings template (use jq for safe JSON value replacement)
echo "[2/4] Exporting settings template..."
if [[ -f "$CLAUDE_DIR/settings.json" ]]; then
    SENSITIVE_KEYS=("ANTHROPIC_AUTH_TOKEN" "ANTHROPIC_BASE_URL" "ANTHROPIC_DEFAULT_HAIKU_MODEL"
                    "ANTHROPIC_DEFAULT_OPUS_MODEL" "ANTHROPIC_DEFAULT_SONNET_MODEL"
                    "ANTHROPIC_MODEL" "ANTHROPIC_REASONING_MODEL")
    if command -v jq &>/dev/null; then
        RESULT=$(cat "$CLAUDE_DIR/settings.json")
        for key in "${SENSITIVE_KEYS[@]}"; do
            RESULT=$(echo "$RESULT" | jq --arg key "$key" '.env[$key] = "{{$key}}"')
        done
        echo "$RESULT" > "$SCRIPT_DIR/config/settings.template.json"
        echo "  -> config/settings.template.json (jq scrubbed)"
    else
        echo "  WARNING: jq not found, using sed fallback. Verify output carefully!" >&2
        WARNINGS=$((WARNINGS + 1))
        SETTINGS=$(cat "$CLAUDE_DIR/settings.json")
        for key in "${SENSITIVE_KEYS[@]}"; do
            SETTINGS=$(echo "$SETTINGS" | sed -E "s|(\"$key\"[[:space:]]*:[[:space:]]*\")([^\"]*)(\")|\1{{${key}}}\3|g")
        done
        echo "$SETTINGS" > "$SCRIPT_DIR/config/settings.template.json"
        echo "  -> config/settings.template.json (sed scrubbed - VERIFY NO REAL TOKENS)"
    fi

    # Safety check: ensure no real tokens leaked
    if grep -qE '[0-9a-f]{30,}' "$SCRIPT_DIR/config/settings.template.json"; then
        echo "  *** CRITICAL WARNING: Possible real token detected in template! ***" >&2
        echo "  *** Do NOT commit until verified! ***" >&2
        WARNINGS=$((WARNINGS + 1))
    fi
fi

# 3. Export plugins manifest
echo "[3/4] Exporting plugins manifest..."
if [[ -f "$CLAUDE_DIR/plugins/installed_plugins.json" ]]; then
    if command -v python3 &>/dev/null; then
        python3 -c "
import json
plugins = json.load(open('$CLAUDE_DIR/plugins/installed_plugins.json'))
manifest = {'plugins': [], 'marketplaces': []}
for pid, info in plugins.items():
    name = pid.split('@')[0]
    marketplace = pid.split('@')[1] if '@' in pid else 'unknown'
    manifest['plugins'].append({'id': pid, 'name': name, 'marketplace': marketplace})

try:
    mkts = json.load(open('$CLAUDE_DIR/plugins/known_marketplaces.json'))
    for mname, info in mkts.items():
        src = info.get('source', {})
        if src.get('source') == 'github':
            manifest['marketplaces'].append({'name': mname, 'source': 'github', 'repo': src.get('repo', '')})
except: pass

json.dump(manifest, open('$SCRIPT_DIR/config/plugins.json', 'w'), indent=2)
"
    else
        echo "  WARNING: python3 not found, plugins.json NOT updated!" >&2
        WARNINGS=$((WARNINGS + 1))
    fi
fi

# 4. Export skills manifest
echo "[4/4] Exporting skills manifest..."
if [[ -f "$AGENTS_DIR/.skill-lock.json" ]]; then
    if command -v python3 &>/dev/null; then
        python3 -c "
import json
lock = json.load(open('$AGENTS_DIR/.skill-lock.json'))
skills = [{'name': k, 'source': v.get('source',''), 'sourceType': v.get('sourceType','')}
          for k, v in lock.get('skills', {}).items()]
json.dump({'skills': skills}, open('$SCRIPT_DIR/config/skills.json', 'w'), indent=2)
"
    else
        echo "  WARNING: python3 not found, skills.json NOT updated!" >&2
        WARNINGS=$((WARNINGS + 1))
    fi
fi

echo ""
if [[ $WARNINGS -gt 0 ]]; then
    echo "=== Export complete with $WARNINGS warning(s)! ===" >&2
    echo "Fix warnings before committing." >&2
else
    echo "=== Export complete! ==="
fi
echo "Review changes and commit:"
echo "  cd $SCRIPT_DIR && git diff"
echo "  git checkout -b update-config  # recommended: review on a branch first"
