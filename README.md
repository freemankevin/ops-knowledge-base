# Ops Knowledge Base

## 项目介绍

ops-knowledge-base 是一个基于 MkDocs 构建的文档项目，用于收集和分享运维相关的知识、经验和工具。


## 🚀 快速开始

### 本地预览

```bash
# 1. 克隆仓库
git clone https://github.com/freemankevin/ops-knowledge-base.git
cd ops-knowledge-base

# 2. 安装依赖
bash scripts/deploy.sh --install

# 3. 启动本地服务
bash scripts/deploy.sh --serve
```

访问 [http://127.0.0.1:8000](http://127.0.0.1:8000) 预览效果。

### 部署脚本使用

```bash
# 安装依赖
bash scripts/deploy.sh --install

# 启动开发服务器
bash scripts/deploy.sh --serve

# 构建静态站点
bash scripts/deploy.sh --build

# 部署到 GitHub Pages
bash scripts/deploy.sh --deploy

# 清理构建文件
bash scripts/deploy.sh --clean

# 查看帮助
bash scripts/deploy.sh --help
```