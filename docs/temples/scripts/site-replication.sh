#!/bin/bash

# 检查必要的环境变量
if [ -z "$SITE1_URL" ] || [ -z "$SITE2_URL" ] || [ -z "$MINIO_ACCESS_KEY" ] || [ -z "$MINIO_SECRET_KEY" ]; then
  echo "Error: Missing required environment variables (SITE1_URL, SITE2_URL, MINIO_ACCESS_KEY, MINIO_SECRET_KEY)"
  exit 1
fi

# 设置 mc 命令的别名
echo "Configuring aliases for SITE1 and SITE2..."
/usr/bin/mc alias set SITE1 "$SITE1_URL" "$MINIO_ACCESS_KEY" "$MINIO_SECRET_KEY"
/usr/bin/mc alias set SITE2 "$SITE2_URL" "$MINIO_ACCESS_KEY" "$MINIO_SECRET_KEY"

# 检查别名是否配置成功
if ! /usr/bin/mc alias list SITE1 >/dev/null 2>&1 || ! /usr/bin/mc alias list SITE2 >/dev/null 2>&1; then
  echo "Error: Failed to configure aliases"
  exit 1
fi

# 配置站点复制
echo "Adding site replication between SITE1 and SITE2..."
/usr/bin/mc admin replicate add SITE1 SITE2

# 检查站点复制状态
if /usr/bin/mc admin replicate status SITE1 >/dev/null 2>&1; then
  echo "Site replication configured successfully!"
else
  echo "Error: Failed to configure site replication"
  exit 1
fi

# 保持容器运行（可选，若需要持久化容器）
tail -f /dev/null
