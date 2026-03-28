#!/bin/bash
# Claude Code completion notification for Windows
# Spawns a detached PowerShell window with a custom alert form

powershell.exe -NoProfile -WindowStyle Hidden -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"$HOME/.claude/hooks/notify-done.ps1\"' -WindowStyle Hidden" &
