---
title: JAVA后端
description: JAVA后端
keywords:
  - JAVA后端
  - 后端
  - 运维
  - 知识库
  - 系统环境
tags:
  - JAVA后端
  - 后端
  - 运维
  - 知识库
  - 系统环境
---

## Dockerfile 模板

```Dockerfile
ARG HARBOR_HOST
ARG BASE_IMAGE_TAG

FROM ${HARBOR_HOST}/library/java-local:${BASE_IMAGE_TAG}

WORKDIR /app

# 构建参数
ARG SERVICE_NAME
ARG PROJECT_ROOT_DIR=demo-sys

# 复制对应服务的 JAR 文件（支持不同的项目根目录）
COPY ${PROJECT_ROOT_DIR}/${SERVICE_NAME}/target/${SERVICE_NAME}-*.jar app.jar

# 环境变量
ENV SPRING_CLOUD_NACOS_CONFIG_SERVER_ADDR=localhost:8848 \
    SPRING_CLOUD_NACOS_DISCOVERY_SERVER_ADDR=localhost:8848 \
    SPRING_CLOUD_NACOS_DISCOVERY_NAMESPACE=public \
    SPRING_CLOUD_NACOS_CONFIG_NAMESPACE=public \
    SPRING_CLOUD_NACOS_DISCOVERY_IP=localhost \
    SPRING_CLOUD_NACOS_USERNAME=nacos \
    SPRING_CLOUD_NACOS_PASSWORD=nacos \
    JAVA_OPTS="-Xms512m -Xmx1024m -Duser.timezone=Asia/Shanghai"


ARG APP_PORT=8080
ENV APP_PORT=${APP_PORT}

# 启动命令
ENTRYPOINT ["sh", "-c", "exec java ${JAVA_OPTS} -jar app.jar --server.port=${APP_PORT}"]
```

## Compose 模板

```yaml
x-common-config: &common-config
  extra_hosts:
    - "localhost.localdomain:127.0.0.1"
  volumes:
    - "/etc/localtime:/etc/localtime:ro"
  restart: always
  networks:
    - apps

services:
  sys-gateway:
    <<: *common-config
    image: "demo/prod/sys-gateway:latest"
    container_name: sys-gateway
    ports:
      - "38099:8099"
    environment:
      SPRING_CLOUD_NACOS_CONFIG_SERVER_ADDR: 127.0.0.1:8848
      SPRING_CLOUD_NACOS_DISCOVERY_SERVER_ADDR: 127.0.0.1:8848
      SPRING_CLOUD_NACOS_DISCOVERY_NAMESPACE: public
      SPRING_CLOUD_NACOS_CONFIG_NAMESPACE: public
      SPRING_CLOUD_NACOS_DISCOVERY_IP: 127.0.0.1
      SPRING_CLOUD_NACOS_USERNAME: nacos
      SPRING_CLOUD_NACOS_PASSWORD: 8dS3^aZ.
      SPRING_CLOUD_NACOS_DISCOVERY_GRPC_PORT: 9848
      SPRING_CLOUD_NACOS_DISCOVERY_PORT: 38099

  sys-system:
    <<: *common-config
    image: "demo/prod/sys-system:latest"
    container_name: sys-system
    ports:
      - "38189:8189"
    environment:
      SPRING_CLOUD_NACOS_CONFIG_SERVER_ADDR: 127.0.0.1:8848
      SPRING_CLOUD_NACOS_DISCOVERY_SERVER_ADDR: 127.0.0.1:8848
      SPRING_CLOUD_NACOS_DISCOVERY_NAMESPACE: public
      SPRING_CLOUD_NACOS_CONFIG_NAMESPACE: public
      SPRING_CLOUD_NACOS_DISCOVERY_IP: 127.0.0.1
      SPRING_CLOUD_NACOS_USERNAME: nacos
      SPRING_CLOUD_NACOS_PASSWORD: 8dS3^aZ.
      SPRING_CLOUD_NACOS_DISCOVERY_GRPC_PORT: 9848
      SPRING_CLOUD_NACOS_DISCOVERY_PORT: 38189

  sys-auth:
    <<: *common-config
    image: "demo/prod/sys-auth:latest"
    container_name: sys-auth
    ports:
      - "38102:8102"
    environment:
      SPRING_CLOUD_NACOS_CONFIG_SERVER_ADDR: 127.0.0.1:8848
      SPRING_CLOUD_NACOS_DISCOVERY_SERVER_ADDR: 127.0.0.1:8848
      SPRING_CLOUD_NACOS_DISCOVERY_NAMESPACE: public
      SPRING_CLOUD_NACOS_CONFIG_NAMESPACE: public
      SPRING_CLOUD_NACOS_DISCOVERY_IP: 127.0.0.1
      SPRING_CLOUD_NACOS_USERNAME: nacos
      SPRING_CLOUD_NACOS_PASSWORD: 8dS3^aZ.
      SPRING_CLOUD_NACOS_DISCOVERY_GRPC_PORT: 9848
      SPRING_CLOUD_NACOS_DISCOVERY_PORT: 38102

networks:
  apps:
    driver: bridge
```