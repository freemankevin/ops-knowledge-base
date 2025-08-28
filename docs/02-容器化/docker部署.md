---
title: Docker 部署
description: Docker 部署
keywords:
  - Docker 部署
  - Linux
  - CentOS
  - Ubuntu
  - Debian
  - 运维
tags:
  - 容器化
  - Linux
  - CentOS
  - Ubuntu
  - Debian
  - 运维
  - 知识库
  - 系统环境
---

# Docker部署

本文档介绍如何在不同Linux发行版上进行Docker的在线安装部署。

---

## CentOS/Red Hat 环境

### 系统要求
- CentOS 7+ 或 Red Hat Enterprise Linux 7+
- 64位系统
- 内核版本 3.10 或更高

### 卸载旧版本（如果存在）
```bash
yum remove docker \
                docker-client \
                docker-client-latest \
                docker-common \
                docker-latest \
                docker-latest-logrotate \
                docker-logrotate \
                docker-engine
```

### 安装步骤

#### 1. 安装依赖包
```bash
yum install -y yum-utils device-mapper-persistent-data lvm2
```

#### 2. 添加Docker官方仓库
```bash
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
```

#### 3. 安装Docker CE
```bash
# 安装最新版本
yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 或安装指定版本（可选）
# yum list docker-ce --showduplicates | sort -r
# yum install -y docker-ce-<VERSION_STRING> docker-ce-cli-<VERSION_STRING> containerd.io
```

#### 4. 启动Docker服务
```bash
# 启动Docker
systemctl start docker

# 设置开机自启
systemctl enable docker
```

#### 5. 配置用户权限（可选）
```bash
# 将当前用户添加到docker组
usermod -aG docker $USER

# 重新登录或执行以下命令使权限生效
newgrp docker
```

---

## Ubuntu/Debian 环境

### 系统要求
- Ubuntu 20.04 LTS+ 或 Debian 10+
- 64位系统
- 内核版本 3.10 或更高

### 卸载旧版本（如果存在）
```bash
apt-get remove docker docker-engine docker.io containerd runc
```

### 安装步骤

#### 1. 更新包索引
```bash
apt-get update
```

#### 2. 安装依赖包
```bash
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```

#### 3. 添加Docker官方GPG密钥
```bash
# 创建密钥目录
mkdir -m 0755 -p /etc/apt/keyrings

# 下载并添加GPG密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

#### 4. 添加Docker仓库
```bash
# Ubuntu系统
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Debian系统
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
```

#### 5. 更新包索引
```bash
apt-get update
```

#### 6. 安装Docker CE
```bash
# 安装最新版本
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 或安装指定版本（可选）
# apt-cache madison docker-ce
# apt-get install -y docker-ce=<VERSION_STRING> docker-ce-cli=<VERSION_STRING> containerd.io
```

#### 7. 启动Docker服务
```bash
# Docker通常会自动启动，如果没有，手动启动
systemctl start docker

# 设置开机自启
systemctl enable docker
```

#### 8. 配置用户权限（可选）
```bash
# 将当前用户添加到docker组
usermod -aG docker $USER

# 重新登录或执行以下命令使权限生效
newgrp docker
```

---

## 验证安装

安装完成后，运行以下命令验证Docker是否正确安装：

```bash
# 查看Docker版本
docker --version

# 查看详细信息
docker info

# 运行Hello World测试容器
docker run hello-world
```

如果看到类似以下输出，说明安装成功：
```
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

---

## 常用配置

### 配置镜像加速器（推荐）

创建或编辑Docker配置文件：
```bash
mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "http://docker.1panel.live",
    "https://docker.agsv.top",
    "https://docker.agsvpt.work",
    "https://dockerpull.com",
    "https://dockerproxy.cn"
  ],
  "debug": false,
  "insecure-registries": [
    "0.0.0.0/0"
  ],
  "ip-forward": true,
  "ipv6": false,
  "live-restore": true,
  "log-driver": "json-file",
  "log-level": "warn",
  "log-opts": {
    "max-size": "100m",
    "max-file": "2"
  },
  "selinux-enabled": false,
  "experimental": true,
  "storage-driver": "overlay2",
  "data-root": "/data/docker_dir",
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 65536,
      "Soft": 65536
    }
  },
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
```

重启Docker服务：
```bash
systemctl daemon-reload
systemctl restart docker
```

### 配置Docker开机自启
```bash
systemctl enable docker
```

---

## 故障排除

### 1. 权限问题
如果出现权限错误，确保用户已添加到docker组：
```bash
usermod -aG docker $USER
# 然后重新登录或执行 newgrp docker
```

### 2. 服务启动失败
检查Docker服务状态：
```bash
systemctl status docker
journalctl -u docker.service
```

### 3. 网络问题
如果无法拉取镜像，检查网络连接和防火墙设置：
```bash
# 测试网络连接
curl -I https://index.docker.io/

# 检查防火墙状态
systemctl status firewalld  # CentOS/RHEL
ufw status                  # Ubuntu/Debian
```

### 4. 存储驱动问题
查看当前使用的存储驱动：
```bash
docker info | grep "Storage Driver"
```

### 5. 清理系统资源
如果需要清理未使用的资源：
```bash
# 清理未使用的容器、网络、镜像
docker system prune

# 清理所有未使用的资源（包括未使用的镜像）
docker system prune -af
```

---

## 相关链接

- [Docker官方文档](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/)
- [Docker Compose文档](https://docs.docker.com/compose/)
