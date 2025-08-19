# 第一阶段：构建MkDocs静态站点
FROM --platform=$BUILDPLATFORM python:3.12-slim AS builder

# 安装系统依赖（如果需要字体或其他，可选）
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# 拷贝项目文件
WORKDIR /app
COPY . /app

# 安装Python依赖，利用你的requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# 构建静态站点
RUN mkdocs build

# 第二阶段：使用Nginx作为web服务器
FROM --platform=$BUILDPLATFORM nginx:alpine

# 拷贝构建好的站点文件到Nginx的html目录
COPY --from=builder /app/site /usr/share/nginx/html

# 暴露端口
EXPOSE 80

# Nginx默认启动命令
CMD ["nginx", "-g", "daemon off;"]