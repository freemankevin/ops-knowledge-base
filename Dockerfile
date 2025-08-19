# 使用 Python 作为基础镜像
FROM python:3.12-slim AS builder

# 设置环境变量，避免缓存和 pyc 文件
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# 设置工作目录
WORKDIR /docs

# 安装必要依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 复制 requirements.txt 并安装依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt



# 复制项目文件（docs/ 配置等）
COPY . .

# 默认运行 MkDocs 开发服务器
EXPOSE 8000
CMD ["mkdocs", "serve", "--dev-addr=0.0.0.0:8000"]
