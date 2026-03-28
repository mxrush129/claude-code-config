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

| 文件 | 说明 |
|------|------|
| settings.template.json | 主配置（模型、hooks、插件） |
| hooks/ | 自定义通知脚本 |
| plugins.json | 插件安装清单 |
| skills.json | 技能安装清单 |

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
