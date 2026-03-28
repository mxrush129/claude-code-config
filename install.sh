#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
AGENTS_DIR="$HOME/.agents"

echo "=== Claude Code Config Installer ==="
echo ""

# 1. Ensure directories exist
mkdir -p "$CLAUDE_DIR/hooks"
mkdir -p "$AGENTS_DIR/skills"

# 2. Read environment variables
ENV_FILE="$SCRIPT_DIR/config/settings.env"
if [[ -f "$ENV_FILE" ]]; then
    echo "[1/6] Loading environment variables..."
    set -a
    source "$ENV_FILE"
    set +a
else
    echo "[1/6] No settings.env found. Using placeholders."
    echo "      Copy config/settings.env.example to config/settings.env and fill in your values."
fi

# 3. Generate settings.json (sed replaces {{VAR}} placeholders)
echo "[2/6] Generating settings.json..."
SETTINGS_TEMPLATE="$SCRIPT_DIR/config/settings.template.json"
if [[ -f "$SETTINGS_TEMPLATE" ]]; then
    sed -e "s|{{ANTHROPIC_AUTH_TOKEN}}|${ANTHROPIC_AUTH_TOKEN:-}|g" \
        -e "s|{{ANTHROPIC_BASE_URL}}|${ANTHROPIC_BASE_URL:-}|g" \
        -e "s|{{ANTHROPIC_DEFAULT_HAIKU_MODEL}}|${ANTHROPIC_DEFAULT_HAIKU_MODEL:-}|g" \
        -e "s|{{ANTHROPIC_DEFAULT_OPUS_MODEL}}|${ANTHROPIC_DEFAULT_OPUS_MODEL:-}|g" \
        -e "s|{{ANTHROPIC_DEFAULT_SONNET_MODEL}}|${ANTHROPIC_DEFAULT_SONNET_MODEL:-}|g" \
        -e "s|{{ANTHROPIC_MODEL}}|${ANTHROPIC_MODEL:-}|g" \
        -e "s|{{ANTHROPIC_REASONING_MODEL}}|${ANTHROPIC_REASONING_MODEL:-}|g" \
        "$SETTINGS_TEMPLATE" > "$CLAUDE_DIR/settings.json"
    echo "      -> $CLAUDE_DIR/settings.json"

    # Check for unreplaced placeholders
    if grep -q '{{' "$CLAUDE_DIR/settings.json"; then
        echo "      WARNING: Some placeholders were not replaced. Edit settings.json manually."
    fi
fi

# 4. Copy hooks
echo "[3/6] Installing hooks..."
cp "$SCRIPT_DIR/config/hooks/"* "$CLAUDE_DIR/hooks/" 2>/dev/null || true
echo "      -> $CLAUDE_DIR/hooks/"
echo "      Note: notify-done hooks are Windows-specific. Adapt for Linux/Mac if needed."

# 5. Install plugins (marketplaces first, then plugins)
echo "[4/6] Installing plugins..."
PLUGINS_FILE="$SCRIPT_DIR/config/plugins.json"
if [[ -f "$PLUGINS_FILE" ]] && command -v claude &>/dev/null; then
    echo "      Adding marketplaces..."
    while IFS= read -r repo; do
        [[ -z "$repo" ]] && continue
        echo "      -> Adding marketplace: $repo"
        claude plugin marketplace add "$repo" 2>/dev/null || echo "      (may already exist)"
    done < <(python3 -c "import json; [print(m['repo']) for m in json.load(open('$PLUGINS_FILE')).get('marketplaces', [])]" 2>/dev/null)

    echo "      Installing plugins..."
    while IFS= read -r pid; do
        [[ -z "$pid" ]] && continue
        echo "      -> Installing: $pid"
        claude plugin install "$pid" 2>/dev/null || echo "      (may already be installed)"
    done < <(python3 -c "import json; [print(p['id']) for p in json.load(open('$PLUGINS_FILE')).get('plugins', [])]" 2>/dev/null)
else
    echo "      Skipped (claude CLI not found or no plugins.json)"
fi

# 6. Install skills (via git clone to ~/.agents/skills/)
echo "[5/6] Installing skills..."
SKILLS_FILE="$SCRIPT_DIR/config/skills.json"
if [[ -f "$SKILLS_FILE" ]]; then
    while IFS='|' read -r source name; do
        [[ -z "$name" ]] && continue
        SKILL_DIR="$AGENTS_DIR/skills/$name"
        if [[ -d "$SKILL_DIR" ]]; then
            echo "      -> Skill '$name' already exists, skipping"
        else
            echo "      -> Installing skill: $name from $source"
            git clone "https://github.com/$source.git" "$AGENTS_DIR/skills/${source//\//-}" --depth 1 2>/dev/null
            if [[ -d "$AGENTS_DIR/skills/${source//\//-}/$name" ]]; then
                ln -s "$AGENTS_DIR/skills/${source//\//-}/$name" "$SKILL_DIR" 2>/dev/null || true
            fi
        fi
    done < <(python3 -c "import json; [print(f\"{s['source']}|{s['name']}\") for s in json.load(open('$SKILLS_FILE')).get('skills', [])]" 2>/dev/null)
else
    echo "      Skipped (no skills.json)"
fi

# 7. Copy memory template to home project directory
echo "[6/6] Setting up memory template..."
if [[ "$(uname -s)" == "Darwin" ]]; then
    PROJECT_MEMORY_DIR="$CLAUDE_DIR/projects/C--Users-$(whoami)/memory"
elif [[ "$(uname -s)" == "MINGW"* || "$(uname -s)" == "MSYS"* ]]; then
    PROJECT_MEMORY_DIR="$CLAUDE_DIR/projects/C--Users-$(whoami)/memory"
else
    PROJECT_MEMORY_DIR="$CLAUDE_DIR/projects/Home--$(whoami)/memory"
fi
mkdir -p "$PROJECT_MEMORY_DIR"
if [[ ! -f "$PROJECT_MEMORY_DIR/MEMORY.md" ]]; then
    cp "$SCRIPT_DIR/memory-templates/MEMORY.example.md" "$PROJECT_MEMORY_DIR/MEMORY.md"
    echo "      -> $PROJECT_MEMORY_DIR/MEMORY.md"
else
    echo "      MEMORY.md already exists, skipping"
fi

echo ""
echo "=== Installation complete! ==="
echo ""
echo "Next steps:"
echo "  1. Edit $CLAUDE_DIR/settings.json to verify your settings"
echo "  2. If you haven't set API keys, edit config/settings.env and re-run"
echo "  3. Restart Claude Code to apply all changes"
echo ""
echo "NOTE: The dashboard plugin is not auto-installed. See README for manual setup."
