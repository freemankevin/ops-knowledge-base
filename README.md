# Ops-Knowledge-Base

![运维知识库](https://img.shields.io/badge/运维知识库-v1.0.0-blue?style=for-the-badge)
[![Docker Hub](https://img.shields.io/badge/Docker-freelabspace/ops--knowledge--base-0db7ed?style=for-the-badge&logo=docker)](https://hub.docker.com/r/freelabspace/ops-knowledge-base)
[![GitHub Pages](https://img.shields.io/badge/GitHub_Pages-Deployed-6cc644?style=for-the-badge&logo=GitHub)](https://freemankevin.github.io/ops-knowledge-base)
[![GitHub](https://img.shields.io/github/license/freemankevin/ops-knowledge-base?style=for-the-badge)](https://github.com/freemankevin/ops-knowledge-base)
[![MkDocs](https://img.shields.io/badge/MkDocs-Material-526CFE?style=for-the-badge&logo=MaterialForMkDocs)](https://squidfunk.github.io/mkdocs-material/)

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