# Codex Mobile 📱

> 手机上的 AI 编程环境 — 基于 Termux + Codex CLI + DeepSeek

## ✨ 特性

- **开箱即用** — 安装后自动配置完成
- **离线配置** — 50+ 预装 Codex Skills
- **中文友好** — 全程中文交互
- **国内直连** — 基于 DeepSeek API，无需翻墙
- **一键启动** — `cyo --zh` 进入中文 AI 编程模式

## 🚀 快速开始

1. 下载最新版 APK 并安装
2. 打开 App → 自动初始化（约 10 秒）
3. 在 Termux 中运行：

```bash
# 安装基础工具
pkg install -y git curl wget

# 安装 Codex CLI
curl -fsSL https://codex.so/install.sh | sh

# 启动
cyo --zh
```

## 🔧 架构

```
┌──────────────────────────────────┐
│        Codex Mobile APK          │
│  ┌────────────────────────────┐  │
│  │     Termux (定制版)        │  │
│  │  ├── .bashrc (预配置)      │  │
│  │  ├── .termux/ (美化)       │  │
│  │  ├── .local/bin/ (工具)    │  │
│  │  └── .codex/skills/ (50+)  │  │
│  └────────────────────────────┘  │
│              ↓                    │
│  ┌────────────────────────────┐  │
│  │  mimo2codex → DeepSeek API │  │
│  └────────────────────────────┘  │
└──────────────────────────────────┘
```

## 📦 构建说明

```bash
# 本地构建
git clone https://github.com/malaxiya2019/codex-mobile.git
cd codex-mobile

# 克隆 Termux 源码
git clone https://github.com/termux/termux-app.git
cd termux-app

# 应用补丁
git apply ../patches/*.patch

# 注入配置
cp -r ../config/* app/src/main/assets/

# 构建
./gradlew assembleDebug
```

## 📄 许可

本项目基于 Termux (GPL-3.0) 修改。
