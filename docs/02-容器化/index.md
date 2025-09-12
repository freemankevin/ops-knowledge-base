---
title: 容器化
description: 容器化技术部署与管理指南，涵盖Docker和Docker Compose的完整部署流程
keywords:
  - 容器化
  - 运维
  - 知识库
  - 系统环境
tags:
  - 容器化
  - 运维
  - 知识库
  - 系统环境
---

# 02-容器化

> 容器化技术部署与管理指南，涵盖Docker和Docker Compose的完整部署流程

## 📦 核心组件

### Docker 部署
- **状态**: 🟢 运行中
- **最后更新**: 3个月前
- **描述**: Docker容器引擎部署指南，支持CentOS/Ubuntu/Debian系统
- **支持版本**: Docker CE 最新版 + 指定版本安装
- **快速访问**: [查看详情](docker部署.md)

### Compose 部署  
- **状态**: 🟢 运行中
- **最后更新**: 3个月前
- **描述**: Docker Compose容器编排工具部署方案
- **支持方式**: 二进制安装 / Python pip / 包管理器
- **快速访问**: [查看详情](compose部署.md)

---

## 🐳 Docker 部署

### 系统支持

| 操作系统 | 版本要求 | 内核版本 | 架构 | 状态 |
|---------|----------|----------|------|------|
| **CentOS/RHEL** | 7+ | 3.10+ | 64位 | ✅ 支持 |
| **Ubuntu** | 20.04 LTS+ | 3.10+ | 64位 | ✅ 支持 |
| **Debian** | 10+ | 3.10+ | 64位 | ✅ 支持 |

### 安装组件
- **Docker CE**: 容器引擎核心
- **Docker CLI**: 命令行工具
- **Containerd**: 容器运行时
- **Docker Buildx**: 多平台构建插件
- **Docker Compose**: 编排工具插件

### 快速安装命令

#### CentOS/RHEL 系统
```bash
# 安装依赖和仓库
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 安装Docker
yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl start docker && systemctl enable docker
```

#### Ubuntu/Debian 系统
```bash
# 安装依赖和GPG密钥
apt-get update && apt-get install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 添加仓库并安装
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list
apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

---

## 🔧 Docker Compose 部署

### 安装方式对比

| 安装方式 | 优势 | 适用场景 | 版本控制 |
|---------|------|----------|----------|
| **二进制安装** | 稳定可控，跨平台 | 生产环境 | ⭐⭐⭐ |
| **Python pip** | 便于升级管理 | 开发环境 | ⭐⭐ |
| **包管理器** | 简单快速 | 快速测试 | ⭐ |

### 推荐安装（二进制方式）
```bash
# 下载最新版本
DOCKER_COMPOSE_VERSION="v2.24.1"
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 设置权限和软链接
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```

### 验证安装
```bash
# 检查版本
docker-compose --version
# 输出: docker-compose version 2.24.1, build 4c9c828
```

---

## ⚙️ 配置优化

### Docker 镜像加速器配置
```json
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "http://docker.1panel.live",
    "https://docker.agsv.top",
    "https://dockerpull.com"
  ],
  "storage-driver": "overlay2",
  "data-root": "/data/docker_dir",
  "log-opts": {
    "max-size": "100m",
    "max-file": "2"
  },
  "exec-opts": ["native.cgroupdriver=systemd"]
}
```

### 服务管理
```bash
# Docker服务管理
systemctl start docker    # 启动
systemctl enable docker   # 开机自启
systemctl status docker   # 查看状态

# 用户权限配置
usermod -aG docker $USER  # 添加到docker组
newgrp docker             # 刷新权限
```

---

## 🧰 常用操作

### 容器管理
```bash
# 基本操作
docker ps                 # 查看运行容器
docker images             # 查看镜像列表
docker system df          # 查看磁盘使用
docker system prune -af   # 清理系统资源
```

### Compose 编排
```bash
# 服务管理
docker-compose up -d           # 后台启动服务
docker-compose ps              # 查看服务状态  
docker-compose logs -f         # 查看实时日志
docker-compose down            # 停止并删除服务
docker-compose up --scale web=3 # 扩展服务实例
```

### 健康检查
```bash
# Docker状态检查
docker info                    # 查看系统信息
docker run hello-world         # 运行测试容器

# 服务连通性测试  
curl -I https://index.docker.io/  # 测试网络连接
systemctl status docker           # 检查服务状态
```

---

## 🔍 故障排除

### 常见问题解决

#### 权限问题
```bash
# 检查用户组
groups $USER

# 重新添加到docker组
sudo usermod -aG docker $USER
newgrp docker
```

#### 网络连接问题
```bash
# 检查防火墙
systemctl status firewalld  # CentOS
ufw status                  # Ubuntu

# 测试镜像源连通性
curl -I https://docker.m.daocloud.io/
```

#### 版本冲突处理
```bash
# 查看所有compose实例
which -a docker-compose

# 清理冲突版本
sudo rm /usr/bin/docker-compose
pip3 uninstall docker-compose
```

---

## 📚 学习资源

### 官方文档
- [Docker 官方文档](https://docs.docker.com/) - 容器技术完整指南
- [Docker Compose 文档](https://docs.docker.com/compose/) - 编排工具使用手册
- [Docker Hub](https://hub.docker.com/) - 官方镜像仓库

### 实践指南
- [Dockerfile 最佳实践](https://docs.docker.com/develop/dev-best-practices/)
- [Docker 网络配置](https://docs.docker.com/network/)
- [数据卷管理](https://docs.docker.com/storage/)

### 进阶主题
- 多阶段构建优化
- 容器安全加固
- 生产环境部署
- 监控和日志管理

---

## 📞 技术支持

### 故障排查流程
1. **检查服务状态**: `systemctl status docker`
2. **查看系统日志**: `journalctl -u docker.service`
3. **验证网络连接**: 测试镜像源访问
4. **权限检查**: 确认用户组配置
5. **版本兼容性**: 检查系统和Docker版本匹配

### 获取帮助
- **命令帮助**: `docker --help` / `docker-compose --help`
- **社区支持**: Docker官方论坛和GitHub Issues
- **在线资源**: Stack Overflow容器化相关问题

---
