# Claude Code Config Template

Personal Claude Code configuration template for syncing across machines.

**[中文文档](README.zh-CN.md)**

## Quick Start

### Prerequisites
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed
- Git installed

### Install on a new machine

**Linux/Mac:**
```bash
git clone https://github.com/mxrush129/claude-code-config.git
cd claude-code-config
chmod +x install.sh
./install.sh
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/mxrush129/claude-code-config.git
cd claude-code-config
.\install.ps1
```

### Configure secrets

After installation, edit the generated settings file:

```bash
cp config/settings.env.example config/settings.env
# Edit with your API token and base URL
```

## What's included

### Plugins

| Plugin | Source | Description |
|--------|--------|-------------|
| [superpowers](https://github.com/anthropics/claude-plugins-official) | anthropics/claude-plugins-official | TDD, debugging, code review, plan execution workflow |
| [frontend-design](https://github.com/anthropics/claude-plugins-official) | anthropics/claude-plugins-official | Production-grade frontend UI generation |
| [skill-creator](https://github.com/anthropics/claude-plugins-official) | anthropics/claude-plugins-official | Create, improve and test skills |
| [document-skills](https://github.com/anthropics/skills) | anthropics/skills | Excel, Word, PowerPoint, PDF processing |
| [ralph-loop](https://github.com/anthropics/claude-plugins-official) | anthropics/claude-plugins-official | Iterative self-referential loop until task completion |

### Skills

| Skill | Source |
|-------|--------|
| frontend-design | [anthropics/skills](https://github.com/anthropics/skills) |
| find-skills | [vercel-labs/skills](https://github.com/vercel-labs/skills) |

### Hooks

| Hook | Trigger | Description |
|------|---------|-------------|
| notify-done.sh / notify-done.ps1 | Task Stop | Windows popup notification when Claude Code finishes working |

### Settings

| Setting | Value |
|---------|-------|
| Model | `opus[1m]` (1M context window) |
| Effort Level | `high` |
| Memory Template | Provided in `memory-templates/MEMORY.example.md` |

## Directory Structure

```
claude-code-config/
├── install.sh                  # Linux/Mac installer
├── install.ps1                 # Windows installer
├── export.sh                   # Export current config to template
├── config/
│   ├── settings.template.json  # Settings template (secrets as placeholders)
│   ├── settings.env.example    # Environment variables example
│   ├── hooks/                  # Notification hooks
│   ├── plugins.json            # Plugin manifest
│   └── skills.json             # Skill manifest
└── memory-templates/
    └── MEMORY.example.md       # Memory file template
```

## Update config from current machine

```bash
./export.sh
```
