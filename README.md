# Codex Mobile 📱

> 手机上的 AI 编程环境 — 基于 Termux + Codex CLI + DeepSeek

**💰 定价：49.9 元**（一次性买断，持续更新）

---

## ✨ 特性

- **开箱即用** — 安装 APK → 自动配置 → 直接使用
- **50+ 预装 Skills** — 代码审查、TDD、架构设计、Bug 诊断等
- **中文友好** — 全程中文交互，无需懂英文
- **国内直连** — 基于 DeepSeek API，无需翻墙
- **一键启动** — `cyo --zh` 进入中文 AI 编程模式
- **完整工具链** — 备份/恢复脚本、状态监控、自动恢复

## 📥 购买方式

| 平台 | 方式 |
|------|------|
| **Gitee** | 扫码付款后，加为仓库协作者（私信 @liang2050） |
| **爱发电** | https://afdian.com/a/liang2050（筹备中） |

## 🚀 快速开始

1. 下载 APK 并安装
2. 打开 App → 自动初始化配置
3. 在 Termux 中运行：

```bash
# 安装 Codex CLI
curl -fsSL https://codex.so/install.sh | sh

# 一键启动
cyo --zh
```

## 📦 包含内容

```
📁 Codex Mobile v1.0
├── 📱 定制 Termux APK
│   ├── 预装 .bashrc（cyo/cy/cs 等别名）
│   ├── 预装终端美化配置
│   └── 预装辅助工具
├── 🤖 50+ Codex Skills
│   ├── code-review      代码审查
│   ├── tdd              测试驱动开发
│   ├── diagnosing-bugs  Bug 诊断
│   ├── codebase-design  架构设计
│   ├── domain-modeling  领域建模
│   └── ... 更多
├── 🔧 工具脚本
│   ├── backup-termux-codex.sh   一键备份
│   ├── restore-codex.sh         一键恢复
│   └── codex-recover            服务恢复
└── 📖 中文文档
    ├── 快速上手.md
    ├── 常见问题.md
    └── 进阶玩法.md
```

## 🔧 技术架构

```
┌──────────────────────────────────┐
│        Codex Mobile APK          │
│  ┌────────────────────────────┐  │
│  │  Termux（预装配置）        │  │
│  │  ├── .bashrc + 别名       │  │
│  │  ├── .termux/ 美化        │  │
│  │  └── .local/bin/ 工具     │  │
│  └──────────┬─────────────────┘  │
│             ↓                    │
│  ┌────────────────────────────┐  │
│  │  mimo2codex → DeepSeek API │  │
│  │  (国内直连，无需代理)      │  │
│  └────────────────────────────┘  │
│             ↓                    │
│  ┌────────────────────────────┐  │
│  │  Codex CLI 0.145.0        │  │
│  │  + 50+ Skills              │  │
│  │  + 中文 Prompt             │  │
│  └────────────────────────────┘  │
└──────────────────────────────────┘
```

## ⚠️ 注意

- 需要自行准备 DeepSeek API Key（可在 platform.deepseek.com 获取）
- 安装后首次使用需联网下载 Codex CLI
- 建议从 F-Droid 安装 Termux 作为补充

## 构建

```bash
# 本地构建
git clone https://github.com/malaxiya2019/codex-mobile.git
cd codex-mobile
# 触发 GitHub Actions 自动构建
git tag v1.0.0 && git push --tags
```
