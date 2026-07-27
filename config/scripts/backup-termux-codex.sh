#!/data/data/com.termux/files/usr/bin/bash
set -e

BACKUP_DIR="$HOME/termux-codex-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "========================================"
echo "  Termux + Codex CLI 一键备份"
echo "  备份目录: $BACKUP_DIR"
echo "========================================"

# ─── 1. Shell 配置 ───
echo ""
echo "📁 [1/10] Shell 配置..."
mkdir -p "$BACKUP_DIR/home"
cp "$HOME/.bashrc"       "$BACKUP_DIR/home/bashrc" 2>/dev/null && echo "  ✓ .bashrc" || echo "  -"
cp "$HOME/.profile"      "$BACKUP_DIR/home/profile" 2>/dev/null && echo "  ✓ .profile" || echo "  -"

# ─── 2. Git 配置 ───
echo ""
echo "📁 [2/10] Git 配置..."
mkdir -p "$BACKUP_DIR/git"
cp "$HOME/.gitconfig"    "$BACKUP_DIR/git/gitconfig" 2>/dev/null && echo "  ✓ .gitconfig" || echo "  -"
if [ -f "$HOME/.git-credentials" ]; then
    echo "# 敏感文件，原内容已移除，恢复时请手动填入" > "$BACKUP_DIR/git/git-credentials"
    echo "# 原始位置: ~/.git-credentials" >> "$BACKUP_DIR/git/git-credentials"
    echo "  ⚠ .git-credentials (已脱敏，含 GitHub/Gitee Token)"
fi

# ─── 3. Codex CLI 核心配置 ───
echo ""
echo "📁 [3/10] Codex CLI 核心配置..."
mkdir -p "$BACKUP_DIR/codex"
cp "$HOME/.codex/config.toml" "$BACKUP_DIR/codex/config.toml" && echo "  ✓ config.toml" || echo "  -"
cp "$HOME/.codex/installation_id" "$BACKUP_DIR/codex/" 2>/dev/null && echo "  ✓ installation_id" || echo "  -"
# auth.json 脱敏
if [ -f "$HOME/.codex/auth.json" ]; then
    echo "{\"openai_key\":\"<REDACTED>\"}" > "$BACKUP_DIR/codex/auth.json"
    echo "  ⚠ auth.json (已脱敏，含 OpenAI API Key)"
fi

# Codex skills
if [ -d "$HOME/.codex/skills" ]; then
    mkdir -p "$BACKUP_DIR/codex/skills"
    cp -r "$HOME/.codex/skills"/* "$BACKUP_DIR/codex/skills/" 2>/dev/null
    echo "  ✓ skills/ ($(find $HOME/.codex/skills -name 'SKILL.md' | wc -l) 个 skill)"
fi

# ─── 4. Termux 配置 ───
echo ""
echo "📁 [4/10] Termux 配置..."
if [ -d "$HOME/.termux" ]; then
    mkdir -p "$BACKUP_DIR/termux"
    cp -r "$HOME/.termux"/* "$BACKUP_DIR/termux/" 2>/dev/null
    echo "  ✓ .termux/ 配置"
fi

# ─── 5. mimo2codex ───
echo ""
echo "📁 [5/10] mimo2codex (DeepSeek API 代理)..."
if [ -d "$HOME/.mimo2codex" ]; then
    mkdir -p "$BACKUP_DIR/mimo2codex"
    # .env 脱敏
    if [ -f "$HOME/.mimo2codex/.env" ]; then
        echo "DS_API_KEY=<REDACTED>" > "$BACKUP_DIR/mimo2codex/env"
        echo "  ⚠ .env (已脱敏，含 DeepSeek API Key)"
    fi
    # version-check 记录
    cp "$HOME/.mimo2codex/version-check.json" "$BACKUP_DIR/mimo2codex/" 2>/dev/null && echo "  ✓ version-check.json" || echo "  -"
    echo "  ℹ data.db 较大 (~32MB)，如需备份请手动执行:"
    echo "    cp ~/.mimo2codex/data.db $BACKUP_DIR/mimo2codex/"
fi

# ─── 6. 辅助工具 (bin) ───
echo ""
echo "📁 [6/10] 辅助工具 (~/.local/bin)..."
mkdir -p "$BACKUP_DIR/bin"
for tool in codex-recover codex-status codex-session auto-save keep-awake threadripper.js; do
    if [ -f "$HOME/.local/bin/$tool" ]; then
        cp "$HOME/.local/bin/$tool" "$BACKUP_DIR/bin/"
        echo "  ✓ $tool"
    fi
done

# ─── 7. 自定义脚本 ───
echo ""
echo "📁 [7/10] 家目录自定义脚本..."
mkdir -p "$BACKUP_DIR/scripts"
for f in "$HOME"/*.sh "$HOME"/CODEX_SYSTEM_PROMPT.md "$HOME"/agent.md "$HOME"/deploy-codex.sh; do
    [ -f "$f" ] && cp "$f" "$BACKUP_DIR/scripts/" && echo "  ✓ $(basename $f)"
done

# ─── 8. pentagi 安装器 ───
echo ""
echo "📁 [8/10] pentagi 安装器..."
if [ -d "$HOME/pentagi-installer" ]; then
    mkdir -p "$BACKUP_DIR/pentagi-installer"
    cp -r "$HOME/pentagi-installer"/* "$BACKUP_DIR/pentagi-installer/" 2>/dev/null
    echo "  ✓ pentagi-installer/"
fi

# ─── 9. 包列表 ───
echo ""
echo "📁 [9/10] 包列表..."
dpkg --get-selections > "$BACKUP_DIR/termux-packages.txt"
echo "  ✓ $(wc -l < "$BACKUP_DIR/termux-packages.txt") 个包已记录"

# ─── 10. 环境信息 ───
echo ""
echo "📁 [10/10] 环境信息..."
{
    echo "# Termux + Codex 环境信息"
    echo "# 备份时间: $(date)"
    echo ""
    echo "=== Codex 版本 ==="
    codex --version 2>/dev/null || echo "未知"
    echo ""
    echo "=== System ==="
    uname -a
    echo ""
    echo "=== Memory ==="
    free -h 2>/dev/null || echo "N/A"
    echo ""
    echo "=== Disk ==="
    df -h /data 2>/dev/null
    echo ""
    echo "=== Cargo 工具 ==="
    ls -1 "$HOME/.cargo/bin" 2>/dev/null
    echo ""
    echo "=== 别名 ==="
    echo "  (alias列表 - 交互式shell中可用)"
    echo ""
    echo "=== PATH ==="
    echo "$PATH"
} > "$BACKUP_DIR/environment-info.txt"
echo "  ✓ environment-info.txt"

# ─── 汇总 ───
echo ""
echo "========================================"
echo "  ✅ 备份完成！"
echo "  目录: $BACKUP_DIR"
echo "  大小: $(du -sh "$BACKUP_DIR" | cut -f1)"
echo "========================================"
echo ""
echo "📋 备份清单:"
find "$BACKUP_DIR" -type f | sort | sed 's|.*/termux-codex-backup-[^/]*/|  📄 |'
echo ""
echo "⚠️  敏感文件（已脱敏，需手动恢复）:"
echo "  1. ~/.codex/auth.json          → OpenAI API Key"
echo "  2. ~/.git-credentials          → GitHub/Gitee Token"
echo "  3. ~/.mimo2codex/.env          → DeepSeek API Key"
echo ""
echo "🔧 快速恢复命令:"
echo "  cp $BACKUP_DIR/home/bashrc  ~/.bashrc"
echo "  cp $BACKUP_DIR/home/profile ~/.profile"
echo "  cp $BACKUP_DIR/git/gitconfig ~/.gitconfig"
echo "  cp $BACKUP_DIR/codex/config.toml ~/.codex/config.toml"
echo "  cp $BACKUP_DIR/codex/installation_id ~/.codex/"
echo "  cp $BACKUP_DIR/codex/skills/* ~/.codex/skills/ -r"
echo "  cp $BACKUP_DIR/termux/* ~/.termux/ -r"
echo "  cp $BACKUP_DIR/bin/* ~/.local/bin/"
echo "  cp $BACKUP_DIR/scripts/* ~/"
echo "  dpkg --set-selections < $BACKUP_DIR/termux-packages.txt"
echo ""
echo "💾 如需打包带走:"
echo "  tar -czf ~/codex-backup.tar.gz -C ~ termux-codex-backup-*"
