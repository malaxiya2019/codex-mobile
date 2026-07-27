#!/data/data/com.termux/files/usr/bin/bash
# ChinaCode - 安装脚本（首次启动后运行）

echo "📦 安装 Codex CLI..."
curl -fsSL https://codex.so/install.sh | CODEX_DANGEROUS_APPROVAL=1 sh

echo "📦 安装 mimo2codex..."
# 根据你的 mimo2codex 安装方式添加
# pkg install -y nodejs && npm install -g mimo2codex

echo ""
echo "✅ 安装完成！输入以下命令启动："
echo "    source ~/.bashrc"
echo "    cyo --zh"
