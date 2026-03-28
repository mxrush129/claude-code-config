# Claude Code Config Template

Personal Claude Code configuration template for syncing across machines.

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

| Item | Description |
|------|-------------|
| settings.template.json | Main settings (model, hooks, plugins) |
| hooks/ | Custom notification hooks |
| plugins.json | Plugin installation list |
| skills.json | Skill installation list |

## Update config from current machine

```bash
./export.sh
```
