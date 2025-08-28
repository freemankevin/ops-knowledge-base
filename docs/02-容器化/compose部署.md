---
title: Compose 部署
description: Compose 部署
keywords:
  - Compose 部署
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

# Docker Compose 部署

---

## 安装前准备

### 系统要求
- 已安装Docker Engine
- Linux 64位系统
- 具有sudo权限的用户账户

### 检查Docker是否已安装
```bash
docker --version
```

如果Docker未安装，请先参考Docker部署文档进行安装。

---

## 方式一：二进制安装

这是最常用和推荐的安装方式，适用于所有Linux发行版。

### CentOS/Red Hat 系统

#### 1. 下载最新版本的Docker Compose
```bash
# 获取最新版本号（可选，也可以直接指定版本）
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)

# 下载二进制文件
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 或者直接指定版本（推荐，更稳定）
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

#### 2. 设置执行权限
```bash
sudo chmod +x /usr/local/bin/docker-compose
```

#### 3. 创建软链接（可选，为了兼容性）
```bash
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```

### Ubuntu/Debian 系统

#### 1. 更新包索引
```bash
sudo apt-get update
```

#### 2. 安装curl（如果未安装）
```bash
sudo apt-get install -y curl
```

#### 3. 下载Docker Compose二进制文件
```bash
# 获取最新版本号（可选）
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)

# 下载二进制文件
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 或者直接指定版本
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

#### 4. 设置执行权限
```bash
sudo chmod +x /usr/local/bin/docker-compose
```

#### 5. 创建软链接（可选）
```bash
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```

---

## 方式二：Python pip 安装

如果系统已安装Python和pip，可以通过pip安装Docker Compose。

### CentOS/Red Hat 系统

#### 1. 安装Python和pip
```bash
# CentOS/RHEL 7
sudo yum install -y python3 python3-pip

# CentOS/RHEL 8/9
sudo dnf install -y python3 python3-pip
```

#### 2. 升级pip
```bash
pip3 install --upgrade pip
```

#### 3. 安装Docker Compose
```bash
# 用户级安装
pip3 install --user docker-compose

# 或系统级安装（需要sudo）
sudo pip3 install docker-compose
```

### Ubuntu/Debian 系统

#### 1. 安装Python和pip
```bash
sudo apt-get update
sudo apt-get install -y python3 python3-pip
```

#### 2. 升级pip
```bash
pip3 install --upgrade pip
```

#### 3. 安装Docker Compose
```bash
# 用户级安装
pip3 install --user docker-compose

# 或系统级安装
sudo pip3 install docker-compose
```

#### 4. 添加到PATH（如果使用用户级安装）
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## 方式三：包管理器安装

### Ubuntu/Debian 系统

```bash
# 更新包索引
sudo apt-get update

# 安装docker-compose
sudo apt-get install -y docker-compose
```

**注意**：通过包管理器安装的版本可能不是最新的。

### CentOS/RHEL 系统

```bash
# 启用EPEL仓库
sudo yum install -y epel-release

# 安装docker-compose
sudo yum install -y docker-compose
```

---

## 验证安装

运行以下命令验证Docker Compose是否正确安装：

```bash
# 查看版本
docker-compose --version

# 查看帮助信息
docker-compose --help
```

期望输出类似于：
```
docker-compose version 2.24.1, build 4c9c828
```

---

## 基本使用

### 创建示例docker-compose.yml文件

```bash
mkdir ~/docker-compose-test
cd ~/docker-compose-test
```

创建一个简单的`docker-compose.yml`文件：

```yaml
version: '3.8'

services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
    restart: unless-stopped

  redis:
    image: redis:alpine
    restart: unless-stopped
```

### 基本命令

```bash
# 启动服务
docker-compose up -d

# 查看运行状态
docker-compose ps

# 查看日志
docker-compose logs

# 停止服务
docker-compose down

# 重新构建并启动
docker-compose up --build -d

# 扩展服务
docker-compose up --scale web=3 -d
```

---

## 升级Docker Compose

### 二进制安装方式升级

```bash
# 查看当前版本
docker-compose --version

# 下载新版本（替换为最新版本号）
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 设置执行权限
sudo chmod +x /usr/local/bin/docker-compose

# 验证升级
docker-compose --version
```

### pip安装方式升级

```bash
# 升级到最新版本
pip3 install --upgrade docker-compose

# 或系统级升级
sudo pip3 install --upgrade docker-compose
```

---

## 卸载Docker Compose

### 二进制安装方式卸载

```bash
# 删除二进制文件
sudo rm /usr/local/bin/docker-compose

# 删除软链接（如果创建了）
sudo rm /usr/bin/docker-compose
```

### pip安装方式卸载

```bash
# 用户级卸载
pip3 uninstall docker-compose

# 系统级卸载
sudo pip3 uninstall docker-compose
```

### 包管理器安装方式卸载

```bash
# Ubuntu/Debian
sudo apt-get remove docker-compose

# CentOS/RHEL
sudo yum remove docker-compose
```

---

## 故障排除

### 1. 权限问题
```bash
# 确保docker-compose有执行权限
ls -l /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 2. 命令未找到
```bash
# 检查PATH
echo $PATH

# 创建软链接
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# 或添加到PATH
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 3. 下载失败
```bash
# 使用代理或镜像源
# 中国用户可以使用以下镜像源
sudo curl -L "https://get.daocloud.io/docker/compose/releases/download/v2.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

### 4. Docker连接问题
```bash
# 检查Docker服务状态
sudo systemctl status docker

# 检查用户是否在docker组中
groups $USER

# 添加用户到docker组
sudo usermod -aG docker $USER
newgrp docker
```

### 5. 版本冲突问题
```bash
# 查看所有docker-compose实例
which -a docker-compose

# 删除冲突的版本
sudo rm /usr/bin/docker-compose
pip3 uninstall docker-compose
```

---

## 最佳实践

### 1. 选择合适的安装方式
- **生产环境**：推荐使用二进制安装方式，版本稳定可控
- **开发环境**：可以使用pip安装，便于升级和管理
- **快速测试**：可以使用包管理器安装

### 2. 版本管理
```bash
# 固定版本号，避免意外升级
COMPOSE_VERSION="v2.24.1"
sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

### 3. 自动补全（可选）
```bash
# 下载补全脚本
sudo curl -L https://raw.githubusercontent.com/docker/compose/master/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose

# 重新加载bash补全
source /etc/bash_completion.d/docker-compose
```

---

## 相关链接

- [Docker Compose 官方文档](https://docs.docker.com/compose/)
- [Docker Compose GitHub仓库](https://github.com/docker/compose)
- [Docker Compose 文件参考](https://docs.docker.com/compose/compose-file/)

