#!/bin/bash

# 配置变量
GITHUB_REPO="https://github.com/freemankevin/ops-knowledge-base.git"
REPO_DIR="ops-knowledge-base"

# 进入仓库目录
cd ~/Desktop/Coding/ops-knowledge-base

# 确保 .gitignore 包含敏感文件
echo "node_modules/" > .gitignore
echo ".env" >> .gitignore

# 添加所有文件并提交
git add .
git commit -m "Cleaned history and prepared for GitHub"

# 设置远程仓库
git remote add origin "$GITHUB_REPO" || git remote set-url origin "$GITHUB_REPO"

# 强制推送
git branch -M main
git push -f origin main

echo "迁移完成！请检查 GitHub 仓库：$GITHUB_REPO"
