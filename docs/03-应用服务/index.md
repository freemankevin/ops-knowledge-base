---
title: 应用服务
description: 应用服务
keywords:
  - 应用服务
  - 运维
  - 知识库
  - 系统环境
tags:
  - 应用服务
  - 运维
  - 知识库
  - 系统环境
---

# 03-应用服务

## 📋 服务概览

### 中间件数据库
- **状态**: 🟢 运行中
- **最后更新**: 3个月前  
- **描述**: Docker Compose 部署的中间件数据库集群
- **包含服务**: Nginx、Nacos、MinIO、Redis、RabbitMQ、PostgreSQL、Elasticsearch、GeoServer
- **快速访问**: [查看详情](中间件数据库.md)

### JAVA后端
- **状态**: 🟢 运行中
- **最后更新**: 3个月前
- **描述**: Java微服务后端系统，基于Spring Cloud架构
- **包含服务**: sys-gateway、sys-system、sys-auth
- **快速访问**: [查看详情](JAVA后端.md)

---

## 🗄️ 中间件数据库服务

### 核心中间件

| 服务名称 | 端口 | 访问地址 | 默认账号 | 状态 |
|---------|------|----------|----------|------|
| **Nginx** | 80 | http://localhost | - | 🟢 |
| **Nacos** | 8848/9848 | http://localhost:8848/nacos | nacos/nacos | 🟢 |
| **MinIO** | 9000/9001 | http://localhost:9001 | admin/lId5p4to | 🟢 |
| **Redis** | 6379 | localhost:6379 | - | 🟢 |
| **RabbitMQ** | 5672/15672 | http://localhost:15672 | admin/feNop7N3 | 🟢 |
| **PostgreSQL** | 5433 | localhost:5433 | postgres/5iQub9fo | 🟢 |
| **Elasticsearch** | 9200 | http://localhost:9200 | elastic/p0y4REbA | 🟢 |
| **GeoServer** | 8080 | http://localhost:8080/geoserver | admin/yoRiK02a | 🟢 |

### 特殊配置
- **Nginx代理**: Portainer (`/portainer/`)、pgAdmin (`/pgadmin/`)
- **MinIO**: 支持HTTP/HTTPS模式，同步复制功能
- **PostgreSQL**: 包含PostGIS扩展和自动备份
- **证书管理**: Let's Encrypt / OpenSSL自签名证书

---

## ☕ JAVA后端服务

### 微服务架构

| 服务名称 | 容器端口 | 宿主机端口 | 镜像 | 状态 |
|---------|----------|------------|------|------|
| **sys-gateway** | 8099 | 38099 | demo/prod/sys-gateway:latest | 🟢 |
| **sys-system** | 8189 | 38189 | demo/prod/sys-system:latest | 🟢 |
| **sys-auth** | 8102 | 38102 | demo/prod/sys-auth:latest | 🟢 |

### 配置信息
- **基础镜像**: `${HARBOR_HOST}/library/java-local:${BASE_IMAGE_TAG}`
- **项目根目录**: demo-sys
- **JVM参数**: `-Xms512m -Xmx1024m -Duser.timezone=Asia/Shanghai`
- **注册中心**: Nacos (localhost:8848)
- **网络模式**: apps (bridge)

---

## 🔧 快速操作

### 中间件管理
```bash
# 启动所有中间件服务
docker-compose up -d

# 启动指定服务
docker-compose up -d nginx redis nacos

# 查看服务状态
docker-compose ps

# 查看服务日志
docker-compose logs -f nacos
```

### Java服务管理
```bash
# 查看Java服务日志
docker logs -f sys-gateway
docker logs -f sys-system  
docker logs -f sys-auth

# 重启服务
docker restart sys-gateway
```

### 健康检查
```bash
# 中间件健康检查
curl -f http://localhost:8848/nacos/
curl -f http://localhost:9000/minio/health/live
redis-cli ping

# Java服务健康检查  
curl http://localhost:38099/health
curl http://localhost:38189/health
curl http://localhost:38102/health
```

---

## 📁 配置文件下载

### 中间件配置
- [mime.types](../temples/configs/mime.types) - Nginx MIME类型配置
- [nginx.conf](../temples/configs/nginx.conf) - Nginx主配置文件
- [web.conf](../temples/configs/web.conf) - Nginx业务配置
- [nacos-standlone.env](../temples/configs/nacos-standlone.env) - Nacos环境配置
- [redis.conf](../temples/configs/redis.conf) - Redis配置文件
- [elasticsearch.yml](../temples/configs/elasticsearch.yml) - Elasticsearch配置

### Java后端模板
- [Dockerfile模板](JAVA后端.md#dockerfile-模板) - 容器构建模板
- [Docker Compose模板](JAVA后端.md#compose-模板) - 服务编排配置

---