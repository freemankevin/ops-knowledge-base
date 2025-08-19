# 运维知识库

![运维知识库](https://img.shields.io/badge/运维知识库-v1.0.0-blue?style=for-the-badge)
[![Docker Hub](https://img.shields.io/badge/Docker-freelabspace/ops--knowledge--base-0db7ed?style=for-the-badge&logo=docker)](https://hub.docker.com/r/freelabspace/ops-knowledge-base)
[![GitHub Pages](https://img.shields.io/badge/GitHub_Pages-Deployed-6cc644?style=for-the-badge&logo=GitHub)](https://freemankevin.github.io/ops-knowledge-base)
[![GitHub](https://img.shields.io/github/license/freemankevin/ops-knowledge-base?style=for-the-badge)](https://github.com/freemankevin/ops-knowledge-base)
[![MkDocs](https://img.shields.io/badge/MkDocs-Material-526CFE?style=for-the-badge&logo=MaterialForMkDocs)](https://squidfunk.github.io/mkdocs-material/)

欢迎来到运维知识库！这是一个专业的运维操作手册和故障解决方案集合，旨在帮助运维工程师快速解决日常工作中遇到的各种问题。

## ✨ 特性

- 📚 **系统性知识体系**：覆盖运维工作的各个方面
- 🔍 **快速检索**：支持全文搜索，快速定位解决方案
- 🌙 **深色模式**：支持浅色/深色主题切换
- 📱 **响应式设计**：完美适配手机、平板、桌面设备
- 🚀 **持续更新**：基于实际工作经验不断完善

## 📖 内容结构

### [🏗️ 基础环境](01-基础环境/index.md)
- 系统安装配置
- 网络环境配置
- 基础软件安装

### [🐳 容器化](02-容器化/index.md)
- Docker 部署指南
- Docker Compose 配置
- 容器编排实践

### [⚙️ 应用服务](03-应用服务/index.md)
- Web 服务配置
- 应用部署流程
- 服务管理实践

### [💾 数据存储](04-数据存储/index.md)
- 数据库管理
- 备份恢复策略
- 存储方案选择

### [📊 监控告警](05-监控告警/index.md)
- 监控系统搭建
- 告警策略配置
- 性能分析方法

### [🔒 安全防护](06-安全防护/index.md)
- 系统安全加固
- 网络安全配置
- 安全事件处理

### [🚨 故障处理](07-故障处理/index.md)
- [常见问题解决](07-故障处理/常见问题.md)
- [应急处理流程](07-故障处理/应急流程.md)
- 故障排查方法

### [⭐ 最佳实践](08-最佳实践/index.md)
- [性能优化指南](08-最佳实践/性能优化.md)
- 运维规范制定
- 团队协作方法

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