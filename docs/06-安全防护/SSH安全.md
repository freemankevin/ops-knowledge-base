---
title: SSH安全配置与访问控制
description: SSH安全配置与访问控制
keywords:
  - SSH安全配置与访问控制
  - 安全防护
  - 运维
  - 知识库
  - 系统环境
tags:
  - SSH安全配置与访问控制
  - 安全防护
  - 运维
  - 知识库
  - 系统环境
---

# SSH安全配置与访问控制

## 1. SSH基础安全配置

### 1.1 修改默认端口

```bash
# 备份原配置文件
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# 修改SSH端口（避免使用22）
vim /etc/ssh/sshd_config
# 修改以下行：
Port 2222

# 如果启用了SELinux，需要添加端口到策略
semanage port -a -t ssh_port_t -p tcp 2222

# 重启SSH服务
systemctl restart sshd

# 验证新端口是否监听
ss -tulnp | grep 2222
```

### 1.2 禁用不安全的功能

```bash
# 编辑SSH配置文件
vim /etc/ssh/sshd_config

# 添加或修改以下配置：
# 禁用root直接登录
PermitRootLogin no

# 禁用空密码登录
PermitEmptyPasswords no

# 禁用密码认证（推荐使用密钥认证）
PasswordAuthentication no

# 禁用质询响应认证
ChallengeResponseAuthentication no

# 禁用Kerberos认证
KerberosAuthentication no

# 禁用GSSAPI认证
GSSAPIAuthentication no

# 禁用主机认证
HostbasedAuthentication no

# 禁用用户环境处理
PermitUserEnvironment no

# 禁用X11转发（如不需要）
X11Forwarding no

# 禁用Agent转发
AllowAgentForwarding no

# 禁用TCP转发
AllowTcpForwarding no

# 限制并发会话数
MaxSessions 2

# 设置最大认证尝试次数
MaxAuthTries 3

# 设置登录宽限时间（秒）
LoginGraceTime 30

# 重启SSH服务
systemctl restart sshd
```

## 2. SSH密钥认证配置

### 2.1 生成和部署SSH密钥

```bash
# 在客户端生成SSH密钥对
ssh-keygen -t rsa -b 4096 -C "admin@yourdomain.com"
# 或使用更安全的ed25519算法
ssh-keygen -t ed25519 -C "admin@yourdomain.com"

# 设置密钥文件权限
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# 将公钥复制到服务器
ssh-copy-id -i ~/.ssh/id_rsa.pub -p 2222 username@server_ip

# 或手动复制
cat ~/.ssh/id_rsa.pub | ssh -p 2222 username@server_ip "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

### 2.2 服务器端密钥管理

```bash
# 在服务器上设置authorized_keys权限
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# 限制密钥功能（在authorized_keys文件中的密钥前添加选项）
vim ~/.ssh/authorized_keys
# 示例：
no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa AAAAB3NzaC1yc2E...

# 创建密钥管理脚本
cat > /usr/local/bin/manage-ssh-keys.sh << 'EOF'
#!/bin/bash

KEYS_DIR="/etc/ssh/authorized_keys"
USER_HOME="/home"

case "$1" in
    add)
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Usage: $0 add <username> <public_key_file>"
            exit 1
        fi
        
        USERNAME="$2"
        KEY_FILE="$3"
        
        if [ ! -f "$KEY_FILE" ]; then
            echo "Key file not found: $KEY_FILE"
            exit 1
        fi
        
        # 创建用户密钥目录
        USER_SSH_DIR="$USER_HOME/$USERNAME/.ssh"
        sudo mkdir -p "$USER_SSH_DIR"
        sudo chmod 700 "$USER_SSH_DIR"
        
        # 添加密钥
        sudo cat "$KEY_FILE" >> "$USER_SSH_DIR/authorized_keys"
        sudo chmod 600 "$USER_SSH_DIR/authorized_keys"
        sudo chown -R "$USERNAME:$USERNAME" "$USER_SSH_DIR"
        
        echo "SSH key added for user $USERNAME"
        ;;
        
    remove)
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Usage: $0 remove <username> <key_fingerprint>"
            exit 1
        fi
        
        USERNAME="$2"
        FINGERPRINT="$3"
        
        USER_SSH_DIR="$USER_HOME/$USERNAME/.ssh"
        AUTHORIZED_KEYS="$USER_SSH_DIR/authorized_keys"
        
        if [ -f "$AUTHORIZED_KEYS" ]; then
            # 创建备份
            sudo cp "$AUTHORIZED_KEYS" "$AUTHORIZED_KEYS.backup.$(date +%Y%m%d_%H%M%S)"
            
            # 删除匹配的密钥
            sudo grep -v "$FINGERPRINT" "$AUTHORIZED_KEYS" > /tmp/authorized_keys_temp
            sudo mv /tmp/authorized_keys_temp "$AUTHORIZED_KEYS"
            sudo chmod 600 "$AUTHORIZED_KEYS"
            sudo chown "$USERNAME:$USERNAME" "$AUTHORIZED_KEYS"
            
            echo "SSH key removed for user $USERNAME"
        else
            echo "No authorized_keys file found for user $USERNAME"
        fi
        ;;
        
    list)
        if [ -z "$2" ]; then
            echo "Usage: $0 list <username>"
            exit 1
        fi
        
        USERNAME="$2"
        AUTHORIZED_KEYS="$USER_HOME/$USERNAME/.ssh/authorized_keys"
        
        if [ -f "$AUTHORIZED_KEYS" ]; then
            echo "SSH keys for user $USERNAME:"
            sudo ssh-keygen -l -f "$AUTHORIZED_KEYS"
        else
            echo "No authorized_keys file found for user $USERNAME"
        fi
        ;;
        
    *)
        echo "Usage: $0 {add|remove|list}"
        echo "  add <username> <public_key_file>"
        echo "  remove <username> <key_fingerprint>"
        echo "  list <username>"
        ;;
esac
EOF

chmod +x /usr/local/bin/manage-ssh-keys.sh
```

## 3. 访问控制和白名单

### 3.1 基于用户的访问控制

```bash
# 在sshd_config中限制用户
vim /etc/ssh/sshd_config

# 只允许特定用户登录
AllowUsers admin user1 user2

# 或者只允许特定组的用户
AllowGroups sshusers admins

# 拒绝特定用户
DenyUsers guest nobody

# 拒绝特定组
DenyGroups noremote

# 创建SSH用户组
groupadd sshusers
usermod -aG sshusers admin
usermod -aG sshusers user1

# 重启SSH服务
systemctl restart sshd
```

### 3.2 基于IP的访问控制

```bash
# 使用TCP Wrappers限制访问
vim /etc/hosts.allow
# 添加允许的IP或网段
sshd: 192.168.1.0/24
sshd: 10.0.0.5
sshd: example.com

vim /etc/hosts.deny
# 拒绝所有其他连接
sshd: ALL

# 或者在sshd_config中使用Match指令
vim /etc/ssh/sshd_config
# 添加条件访问控制
Match Address 192.168.1.0/24
    PasswordAuthentication yes
    
Match Address !192.168.1.0/24
    PasswordAuthentication no
    PubkeyAuthentication yes

# 重启SSH服务
systemctl restart sshd
```

## 4. SSH连接监控和日志

### 4.1 增强SSH日志

```bash
# 在sshd_config中启用详细日志
vim /etc/ssh/sshd_config
LogLevel VERBOSE

# 配置rsyslog分离SSH日志
vim /etc/rsyslog.d/ssh.conf
# 添加以下内容
# SSH日志分离
:programname, isequal, "sshd" /var/log/ssh.log
& stop

# 重启服务
systemctl restart rsyslog sshd

# 创建SSH日志分析脚本
cat > /usr/local/bin/ssh-log-analyzer.sh << 'EOF'
#!/bin/bash

LOG_FILE="/var/log/ssh.log"
REPORT_FILE="/var/log/ssh-report.txt"
DATE=$(date '+%Y-%m-%d')

echo "SSH日志分析报告 - $DATE" > $REPORT_FILE
echo "=================================" >> $REPORT_FILE

# 统计登录成功的记录
echo "成功登录统计:" >> $REPORT_FILE
grep "Accepted" $LOG_FILE | awk '{print $1, $2, $3, $9, $11}' | sort | uniq -c | sort -nr >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 统计登录失败的记录
echo "登录失败统计:" >> $REPORT_FILE
grep "Failed password" $LOG_FILE | awk '{print $1, $2, $3, $9, $11}' | sort | uniq -c | sort -nr | head -20 >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 统计攻击IP
echo "攻击IP TOP 10:" >> $REPORT_FILE
grep "Failed password" $LOG_FILE | awk '{print $11}' | sort | uniq -c | sort -nr | head -10 >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 检查异常登录
echo "异常时间登录 (非工作时间 18:00-08:00):" >> $REPORT_FILE
grep "Accepted" $LOG_FILE | awk '$3 ~ /^(1[8-9]|2[0-3]|0[0-7]):/ {print}' >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 发送报告邮件（需要配置邮件服务）
# mail -s "SSH日志分析报告 - $(hostname)" admin@yourdomain.com < $REPORT_FILE
EOF

chmod +x /usr/local/bin/ssh-log-analyzer.sh

# 添加到每日任务
echo "0 7 * * * /usr/local/bin/ssh-log-analyzer.sh" | crontab -
```

### 4.2 实时SSH监控

```bash
# 创建SSH实时监控脚本
cat > /usr/local/bin/ssh-monitor.sh << 'EOF'
#!/bin/bash

ALERT_EMAIL="admin@yourdomain.com"
FAIL_THRESHOLD=5
LOG_FILE="/var/log/ssh.log"
TEMP_FILE="/tmp/ssh_failures.tmp"

# 监控SSH失败登录
tail -F $LOG_FILE | while read line; do
    if echo "$line" | grep -q "Failed password"; then
        IP=$(echo "$line" | awk '{print $11}')
        TIMESTAMP=$(echo "$line" | awk '{print $1, $2, $3}')
        
        # 记录失败尝试
        echo "$TIMESTAMP $IP" >> $TEMP_FILE
        
        # 统计最近5分钟内的失败次数
        RECENT_FAILS=$(grep "$IP" $TEMP_FILE | wc -l)
        
        if [ $RECENT_FAILS -ge $FAIL_THRESHOLD ]; then
            # 发送警报
            echo "SSH暴力攻击检测到！IP: $IP, 失败次数: $RECENT_FAILS, 时间: $TIMESTAMP" | \
                logger -t ssh-monitor
            
            # 自动封禁IP（可选）
            iptables -I INPUT -s $IP -j DROP
            echo "IP $IP has been blocked due to SSH brute force attack" | \
                logger -t ssh-monitor
                
            # 清理临时记录
            grep -v "$IP" $TEMP_FILE > $TEMP_FILE.tmp
            mv $TEMP_FILE.tmp $TEMP_FILE
        fi
    fi
    
    # 清理5分钟前的记录
    find $TEMP_FILE -mmin +5 -delete 2>/dev/null
done &
EOF

chmod +x /usr/local/bin/ssh-monitor.sh

# 创建systemd服务
cat > /etc/systemd/system/ssh-monitor.service << 'EOF'
[Unit]
Description=SSH Monitor Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/ssh-monitor.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable ssh-monitor
systemctl start ssh-monitor
```

## 5. SSH高级安全功能

### 5.1 配置SSH Certificate Authority

```bash
# 创建CA密钥
ssh-keygen -t rsa -b 4096 -f /etc/ssh/ca_key -C "SSH CA"

# 配置sshd使用CA
vim /etc/ssh/sshd_config
# 添加：
TrustedUserCAKeys /etc/ssh/ca_key.pub

# 为用户创建证书
ssh-keygen -s /etc/ssh/ca_key -I "user_cert" -n admin,root -V +1w ~/.ssh/id_rsa.pub

# 重启SSH服务
systemctl restart sshd
```

### 5.2 SSH会话记录

```bash
# 安装ttyrec或script工具记录会话
yum install ttyrec -y  # CentOS/RHEL
apt install ttyrec -y  # Ubuntu/Debian

# 创建会话记录脚本
cat > /etc/profile.d/session-record.sh << 'EOF'
#!/bin/bash

# 只对SSH会话启用录制
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    SESSION_LOG_DIR="/var/log/sessions"
    SESSION_LOG="$SESSION_LOG_DIR/$(whoami)_$(date +%Y%m%d_%H%M%S)_$"
    
    # 创建日志目录
    sudo mkdir -p $SESSION_LOG_DIR
    sudo chmod 755 $SESSION_LOG_DIR
    
    # 记录会话开始
    echo "Session started: $(date) by $(whoami) from ${SSH_CLIENT%% *}" | sudo tee -a "$SESSION_LOG.info"
    
    # 启动记录
    exec script -q -f -c "$SHELL" "$SESSION_LOG"
fi
EOF

chmod +x /etc/profile.d/session-record.sh
```

### 5.3 SSH多因素认证 (MFA)

```bash
# 安装Google Authenticator PAM模块
yum install epel-release -y
yum install google-authenticator-libpam -y  # CentOS/RHEL
apt install libpam-google-authenticator -y  # Ubuntu/Debian

# 为用户设置Google Authenticator
su - admin
google-authenticator
# 按照提示完成设置，保存密钥和备份码

# 配置PAM
vim /etc/pam.d/sshd
# 在文件开头添加：
auth required pam_google_authenticator.so

# 配置SSH支持键盘交互认证
vim /etc/ssh/sshd_config
# 修改或添加：
ChallengeResponseAuthentication yes
AuthenticationMethods publickey,keyboard-interactive

# 重启SSH服务
systemctl restart sshd
```

## 6. SSH隧道和端口转发安全

### 6.1 限制隧道功能

```bash
# 在sshd_config中限制隧道功能
vim /etc/ssh/sshd_config

# 禁用所有隧道功能
AllowTcpForwarding no
AllowStreamLocalForwarding no
GatewayPorts no

# 或者有选择性地启用
AllowTcpForwarding local  # 只允许本地转发
GatewayPorts clientspecified  # 限制网关端口

# 对特定用户禁用隧道
Match User restricteduser
    AllowTcpForwarding no
    X11Forwarding no
    PermitTunnel no

systemctl restart sshd
```

### 6.2 监控SSH隧道活动

```bash
# 创建隧道监控脚本
cat > /usr/local/bin/ssh-tunnel-monitor.sh << 'EOF'
#!/bin/bash

LOGFILE="/var/log/ssh-tunnels.log"

# 检查当前SSH连接
netstat -tnp | grep sshd | while read line; do
    PID=$(echo "$line" | awk '{print $7}' | cut -d'/' -f1)
    if [ -n "$PID" ]; then
        # 检查进程的端口转发
        FORWARDS=$(lsof -p $PID 2>/dev/null | grep LISTEN)
        if [ -n "$FORWARDS" ]; then
            TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
            echo "[$TIMESTAMP] SSH Tunnel detected - PID: $PID" >> $LOGFILE
            echo "$FORWARDS" >> $LOGFILE
            echo "---" >> $LOGFILE
        fi
    fi
done
EOF

chmod +x /usr/local/bin/ssh-tunnel-monitor.sh

# 每5分钟检查一次
echo "*/5 * * * * /usr/local/bin/ssh-tunnel-monitor.sh" | crontab -
```

## 7. SSH安全自动化脚本

### 7.1 SSH安全配置检查脚本

```bash
cat > /usr/local/bin/ssh-security-check.sh << 'EOF'
#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SSHD_CONFIG="/etc/ssh/sshd_config"
REPORT_FILE="/var/log/ssh-security-check.log"

echo "SSH Security Check Report - $(date)" > $REPORT_FILE
echo "==========================================" >> $REPORT_FILE

# 检查SSH配置项
check_config() {
    local setting="$1"
    local expected="$2"
    local description="$3"
    
    actual=$(grep "^$setting" $SSHD_CONFIG | awk '{print $2}')
    
    if [ "$actual" = "$expected" ]; then
        echo -e "${GREEN}[PASS]${NC} $description: $actual" | tee -a $REPORT_FILE
    else
        echo -e "${RED}[FAIL]${NC} $description: Expected '$expected', Found '$actual'" | tee -a $REPORT_FILE
    fi
}

# 执行安全检查
echo "SSH Security Configuration Check:"
check_config "Port" "2222" "SSH Port"
check_config "PermitRootLogin" "no" "Root Login"
check_config "PasswordAuthentication" "no" "Password Authentication"
check_config "PermitEmptyPasswords" "no" "Empty Passwords"
check_config "X11Forwarding" "no" "X11 Forwarding"
check_config "AllowTcpForwarding" "no" "TCP Forwarding"
check_config "MaxAuthTries" "3" "Max Auth Tries"
check_config "LoginGraceTime" "30" "Login Grace Time"

# 检查SSH密钥权限
echo -e "\n${YELLOW}Checking SSH Key Permissions:${NC}" | tee -a $REPORT_FILE
find /home -name "authorized_keys" -exec ls -la {} \; | while read perm links owner group size date time file; do
    if [[ $perm != "-rw-------" ]]; then
        echo -e "${RED}[FAIL]${NC} Wrong permissions on $file: $perm" | tee -a $REPORT_FILE
    else
        echo -e "${GREEN}[PASS]${NC} Correct permissions on $file: $perm" | tee -a $REPORT_FILE
    fi
done

# 检查最近的SSH攻击
echo -e "\n${YELLOW}Recent SSH Attack Attempts:${NC}" | tee -a $REPORT_FILE
grep "Failed password" /var/log/secure 2>/dev/null | tail -10 | tee -a $REPORT_FILE

# 检查当前SSH连接
echo -e "\n${YELLOW}Current SSH Connections:${NC}" | tee -a $REPORT_FILE
ss -tnp | grep sshd | tee -a $REPORT_FILE

echo -e "\nReport saved to: $REPORT_FILE"
EOF

chmod +x /usr/local/bin/ssh-security-check.sh
```

### 7.2 SSH自动封禁脚本 (Fail2Ban替代)

```bash
cat > /usr/local/bin/ssh-autoban.sh << 'EOF'
#!/bin/bash

LOGFILE="/var/log/secure"
BANLIST="/var/log/ssh-banned-ips.log"
WHITELIST="/etc/ssh/whitelist-ips.conf"
BAN_TIME=3600  # 封禁时间（秒）
MAX_ATTEMPTS=5  # 最大尝试次数
TIME_WINDOW=600  # 时间窗口（秒）

# 创建白名单文件（如果不存在）
if [ ! -f "$WHITELIST" ]; then
    cat > $WHITELIST << 'EOFWHITE'
127.0.0.1
192.168.1.0/24
10.0.0.0/8
EOFWHITE
fi

# 检查IP是否在白名单中
is_whitelisted() {
    local ip="$1"
    while read -r whitelist_entry; do
        # 跳过注释和空行
        [[ $whitelist_entry =~ ^#.*$ ]] && continue
        [[ -z "$whitelist_entry" ]] && continue
        
        # 检查IP是否匹配
        if [[ "$ip" == "$whitelist_entry" ]]; then
            return 0
        fi
        
        # 检查网段匹配（简化版本）
        if [[ "$whitelist_entry" == *"/"* ]]; then
            network=$(echo "$whitelist_entry" | cut -d'/' -f1)
            if [[ "$ip" == "$network"* ]]; then
                return 0
            fi
        fi
    done < "$WHITELIST"
    return 1
}

# 封禁IP
ban_ip() {
    local ip="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # 检查是否已经封禁
    if iptables -L INPUT -n | grep -q "$ip"; then
        return 0
    fi
    
    # 添加iptables规则
    iptables -I INPUT -s "$ip" -j DROP
    
    # 记录封禁
    echo "[$timestamp] Banned IP: $ip" >> $BANLIST
    logger -t ssh-autoban "Banned IP: $ip due to SSH brute force attack"
    
    # 设置定时解封
    echo "sleep $BAN_TIME && iptables -D INPUT -s $ip -j DROP && echo \"[$timestamp] Unbanned IP: $ip\" >> $BANLIST" | at now
}

# 分析日志并封禁恶意IP
analyze_log() {
    # 获取最近时间窗口内的失败登录
    since_time=$(date -d "$TIME_WINDOW seconds ago" '+%b %d %H:%M:%S')
    
    # 提取失败的SSH登录尝试
    grep "Failed password" $LOGFILE | \
    awk -v since="$since_time" '
        BEGIN { 
            # 将since_time转换为可比较的格式
            cmd = "date -d \"" since "\" +%s"
            cmd | getline since_epoch
            close(cmd)
        }
        {
            # 提取时间戳和IP
            timestamp = $1 " " $2 " " $3
            ip = $11
            
            # 转换当前行时间戳为epoch
            cmd = "date -d \"" timestamp "\" +%s 2>/dev/null"
            if ((cmd | getline current_epoch) > 0) {
                close(cmd)
                if (current_epoch >= since_epoch) {
                    count[ip]++
                }
            }
        }
        END {
            for (ip in count) {
                if (count[ip] >= '$MAX_ATTEMPTS') {
                    print ip, count[ip]
                }
            }
        }
    ' | while read ip attempts; do
        # 检查白名单
        if ! is_whitelisted "$ip"; then
            echo "IP $ip has $attempts failed attempts, banning..."
            ban_ip "$ip"
        else
            echo "IP $ip is whitelisted, skipping ban"
        fi
    done
}

# 主执行
case "$1" in
    start)
        echo "Starting SSH auto-ban monitoring..."
        analyze_log
        ;;
    unban)
        if [ -z "$2" ]; then
            echo "Usage: $0 unban <ip_address>"
            exit 1
        fi
        iptables -D INPUT -s "$2" -j DROP 2>/dev/null
        echo "IP $2 has been unbanned"
        ;;
    status)
        echo "Currently banned IPs:"
        iptables -L INPUT -n | grep DROP | awk '{print $4}' | grep -v "0.0.0.0/0"
        ;;
    *)
        echo "Usage: $0 {start|unban <ip>|status}"
        ;;
esac
EOF

chmod +x /usr/local/bin/ssh-autoban.sh

# 创建定时任务，每分钟检查一次
echo "* * * * * /usr/local/bin/ssh-autoban.sh start >/dev/null 2>&1" | crontab -

# 创建系统服务（可选）
cat > /etc/systemd/system/ssh-autoban.service << 'EOF'
[Unit]
Description=SSH Auto-ban Service
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/ssh-autoban.sh start

[Install]
WantedBy=multi-user.target
EOF

# 创建定时器
cat > /etc/systemd/system/ssh-autoban.timer << 'EOF'
[Unit]
Description=SSH Auto-ban Timer
Requires=ssh-autoban.service

[Timer]
OnCalendar=*:*:0
Persistent=true

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable ssh-autoban.timer
systemctl start ssh-autoban.timer
```

## 8. SSH安全维护checklist

```bash
# 创建SSH安全维护清单脚本
cat > /usr/local/bin/ssh-maintenance.sh << 'EOF'
#!/bin/bash

echo "SSH Security Maintenance Checklist"
echo "=================================="

echo "1. 检查SSH配置文件语法..."
sshd -t && echo "✓ SSH配置语法正确" || echo "✗ SSH配置语法错误"

echo "2. 检查SSH服务状态..."
systemctl is-active sshd >/dev/null && echo "✓ SSH服务运行正常" || echo "✗ SSH服务未运行"

echo "3. 检查SSH端口监听..."
ss -tnlp | grep -q ":$(grep "^Port" /etc/ssh/sshd_config | awk '{print $2}')" && echo "✓ SSH端口监听正常" || echo "✗ SSH端口监听异常"

echo "4. 检查最近24小时的SSH攻击..."
attacks=$(grep "$(date --date='1 day ago' '+%b %d')" /var/log/secure 2>/dev/null | grep "Failed password" | wc -l)
echo "   最近24小时失败登录尝试: $attacks 次"

echo "5. 检查当前活跃SSH连接..."
active=$(ss -tn | grep :$(grep "^Port" /etc/ssh/sshd_config | awk '{print $2}') | grep ESTAB | wc -l)
echo "   当前活跃连接数: $active"

echo "6. 检查SSH密钥权限..."
find /home -name ".ssh" -type d -exec ls -ld {} \; | awk '$1 !~ /^drwx------/ {print "✗ Wrong permission: " $9}' | head -5

echo "7. 检查authorized_keys文件..."
find /home -name "authorized_keys" -exec ls -l {} \; | awk '$1 !~ /^-rw-------/ {print "✗ Wrong permission: " $9}' | head -5

echo "8. 清理过期的会话记录..."
find /var/log/sessions -type f -mtime +30 -delete 2>/dev/null
echo "✓ 清理30天前的会话记录"

echo "9. 轮转SSH日志..."
logrotate -f /etc/logrotate.d/ssh 2>/dev/null
echo "✓ SSH日志轮转完成"

echo "10. 更新IP封禁列表..."
/usr/local/bin/ssh-autoban.sh start
echo "✓ IP封禁检查完成"

echo ""
echo "SSH安全维护完成 - $(date)"
EOF

chmod +x /usr/local/bin/ssh-maintenance.sh

# 设置每周运行维护脚本
echo "0 6 * * 0 /usr/local/bin/ssh-maintenance.sh | mail -s 'SSH Security Maintenance Report' admin@yourdomain.com" | crontab -
```