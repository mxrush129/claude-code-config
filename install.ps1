#Requires -Version 5.1
param(
    [string]$ConfigDir = "$PSScriptRoot\config"
)

$ErrorActionPreference = "Stop"
$ClaudeDir = "$env:USERPROFILE\.claude"
$AgentsDir = "$env:USERPROFILE\.agents"

Write-Host "=== Claude Code Config Installer (Windows) ===" -ForegroundColor Cyan
Write-Host ""

# 1. Ensure directories exist
New-Item -ItemType Directory -Force -Path "$ClaudeDir\hooks" | Out-Null
New-Item -ItemType Directory -Force -Path "$AgentsDir\skills" | Out-Null

# 2. Read environment variables (session-only, NOT written to registry)
$EnvFile = "$ConfigDir\settings.env"
if (Test-Path $EnvFile) {
    Write-Host "[1/6] Loading environment variables..." -ForegroundColor Green
    Get-Content $EnvFile | ForEach-Object {
        if ($_ -match '^\s*([A-Za-z_][A-Za-z0-9_]*)=(.*)$') {
            $varName = $matches[1]
            $varValue = $matches[2].Trim()
            Set-Variable -Name $varName -Value $varValue
            Set-Item -Path "env:$varName" -Value $varValue
        }
    }
} else {
    Write-Host "[1/6] No settings.env found." -ForegroundColor Yellow
}

# 3. Generate settings.json
Write-Host "[2/6] Generating settings.json..." -ForegroundColor Green
$Template = Get-Content "$ConfigDir\settings.template.json" -Raw
$Settings = $Template
@("ANTHROPIC_AUTH_TOKEN", "ANTHROPIC_BASE_URL", "ANTHROPIC_DEFAULT_HAIKU_MODEL",
  "ANTHROPIC_DEFAULT_OPUS_MODEL", "ANTHROPIC_DEFAULT_SONNET_MODEL",
  "ANTHROPIC_MODEL", "ANTHROPIC_REASONING_MODEL") | ForEach-Object {
    $val = if (Get-Variable $_ -ErrorAction SilentlyContinue) { (Get-Variable $_).Value } else { "" }
    $Settings = $Settings.Replace("{{$_}}", $val)
}
if ($Settings -match '{{') {
    Write-Host "      WARNING: Some placeholders were not replaced." -ForegroundColor Yellow
}
$Settings | Set-Content "$ClaudeDir\settings.json" -Encoding UTF8
Write-Host "      -> $ClaudeDir\settings.json"

# 4. Copy hooks
Write-Host "[3/6] Installing hooks..." -ForegroundColor Green
Copy-Item "$ConfigDir\hooks\*" "$ClaudeDir\hooks\" -Force
Write-Host "      -> $ClaudeDir\hooks\"

# 5. Install plugins
Write-Host "[4/6] Installing plugins..." -ForegroundColor Green
$PluginsJson = Get-Content "$ConfigDir\plugins.json" -Raw | ConvertFrom-Json
if (Get-Command claude -ErrorAction SilentlyContinue) {
    foreach ($m in $PluginsJson.marketplaces) {
        Write-Host "      Adding marketplace: $($m.repo)"
        & claude plugin marketplace add $m.repo 2>$null
    }
    foreach ($p in $PluginsJson.plugins) {
        Write-Host "      Installing: $($p.id)"
        & claude plugin install $p.id 2>$null
    }
} else {
    Write-Host "      Skipped (claude CLI not found)" -ForegroundColor Yellow
}

# 6. Install skills (via git clone to ~/.agents/skills/)
Write-Host "[5/6] Installing skills..." -ForegroundColor Green
$SkillsJson = Get-Content "$ConfigDir\skills.json" -Raw | ConvertFrom-Json
foreach ($s in $SkillsJson.skills) {
    $SkillDir = "$AgentsDir\skills\$($s.name)"
    if (Test-Path $SkillDir) {
        Write-Host "      Skill '$($s.name)' already exists, skipping"
    } else {
        Write-Host "      Installing skill: $($s.name) from $($s.source)"
        $CloneDir = "$AgentsDir\skills\$($s.source -replace '/','-')"
        if (-not (Test-Path $CloneDir)) {
            & git clone "https://github.com/$($s.source).git" $CloneDir --depth 1 2>$null
        }
        $SubDir = "$CloneDir\$($s.name)"
        if (Test-Path $SubDir) {
            New-Item -ItemType SymbolicLink -Path $SkillDir -Target $SubDir -Force | Out-Null
        }
    }
}

# 7. Memory template
Write-Host "[6/6] Setting up memory template..." -ForegroundColor Green
$UserName = $env:USERNAME
$MemoryDir = "$ClaudeDir\projects\C--Users-$UserName\memory"
New-Item -ItemType Directory -Force -Path $MemoryDir | Out-Null
if (-not (Test-Path "$MemoryDir\MEMORY.md")) {
    Copy-Item "$PSScriptRoot\memory-templates\MEMORY.example.md" "$MemoryDir\MEMORY.md"
    Write-Host "      -> $MemoryDir\MEMORY.md"
} else {
    Write-Host "      MEMORY.md already exists, skipping"
}

Write-Host ""
Write-Host "=== Installation complete! ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Verify $ClaudeDir\settings.json"
Write-Host "  2. Set API keys in settings.env if needed"
Write-Host "  3. Restart Claude Code"
Write-Host ""
Write-Host "NOTE: The dashboard plugin is not auto-installed. See README for manual setup." -ForegroundColor Yellow
