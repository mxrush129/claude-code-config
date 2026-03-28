# Claude Code 配置模板

跨机器同步 Claude Code 配置的个人模板仓库。

## 快速开始

### 前置条件
- 已安装 [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)
- 已安装 Git

### 在新机器上安装

**Linux/Mac：**
```bash
git clone https://github.com/mxrush129/claude-code-config.git
cd claude-code-config
chmod +x install.sh
./install.sh
```

**Windows (PowerShell)：**
```powershell
git clone https://github.com/mxrush129/claude-code-config.git
cd claude-code-config
.\install.ps1
```

### 配置密钥

安装后，填入你的 API Token：

```bash
cp config/settings.env.example config/settings.env
# 编辑 settings.env，填入你的 API Token 和 Base URL
```

## 包含内容

### 插件

| 插件 | 来源 | 说明 |
|------|------|------|
| [superpowers](https://github.com/anthropics/claude-plugins-official) | anthropics/claude-plugins-official | TDD、调试、代码审查、计划执行工作流 |
| [frontend-design](https://github.com/anthropics/claude-plugins-official) | anthropics/claude-plugins-official | 生产级前端 UI 生成 |
| [skill-creator](https://github.com/anthropics/claude-plugins-official) | anthropics/claude-plugins-official | 创建、改进和测试技能 |
| [document-skills](https://github.com/anthropics/skills) | anthropics/skills | Excel、Word、PowerPoint、PDF 文档处理 |

### 技能

| 技能 | 来源 |
|------|------|
| frontend-design | [anthropics/skills](https://github.com/anthropics/skills) |
| find-skills | [vercel-labs/skills](https://github.com/vercel-labs/skills) |

### Hooks

| Hook | 触发时机 | 说明 |
|------|---------|------|
| notify-done.sh / notify-done.ps1 | 任务停止时 | Claude Code 完成工作时弹出 Windows 通知 |

### 配置

| 配置项 | 值 |
|--------|-----|
| 模型 | `opus[1m]`（1M 上下文窗口） |
| Effort Level | `high` |
| Memory 模板 | 见 `memory-templates/MEMORY.example.md` |

## 从当前机器更新配置

在已有配置的机器上运行导出脚本，将最新配置同步到模板：

```bash
./export.sh
```

## 目录结构

```
claude-code-config/
├── install.sh              # Linux/Mac 安装脚本
├── install.ps1             # Windows 安装脚本
├── export.sh               # 导出当前配置到模板
├── config/
│   ├── settings.template.json  # settings 模板（敏感值已脱敏）
│   ├── settings.env.example    # 环境变量示例
│   ├── hooks/                  # 通知脚本
│   ├── plugins.json            # 插件清单
│   └── skills.json             # 技能清单
└── memory-templates/
    └── MEMORY.example.md       # Memory 文件模板
```

## 注意事项

- API Token 等敏感信息不会提交到仓库，使用 `{{占位符}}` 替代
- dashboard 插件是本地构建的，不会自动安装，需手动设置
- hooks 中的通知脚本仅适用于 Windows，Linux/Mac 需自行适配
