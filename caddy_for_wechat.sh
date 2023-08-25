#!/bin/bash

# 安装 Caddy
echo "正在更新软件源..."
apt update
apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor | tee /usr/share/keyrings/caddy-archive-keyring.gpg >/dev/null 2>&1
echo "deb [signed-by=/usr/share/keyrings/caddy-archive-keyring.gpg] https://dl.cloudsmith.io/public/caddy/stable/deb/debian any-version main" | tee /etc/apt/sources.list.d/caddy.list
apt update
echo "正在安装 Caddy..."
apt install -y caddy

echo "开始配置微信代理..."
# 获取用户输入的域名或 IP 地址
read -p "是否使用域名？(y/n): " use_domain

if [ "$use_domain" == "y" ]; then
    read -p "请输入您的域名: " domain
else
    ip_address=$(curl -sS ipinfo.io/ip)
fi

# 获取用户选择的端口
read -p "请输入端口号 (默认为80，如被占用请更换): " port
port=${port:-80}

# 配置 Caddy
echo "正在将微信代理配置写入 Caddy..."
cat <<EOF >/etc/caddy/Caddyfile
EOF

if [ "$use_domain" == "y" ]; then
    echo "${domain}:${port} {" >> /etc/caddy/Caddyfile
else
    echo "${ip_address}:${port} {" >> /etc/caddy/Caddyfile
fi

echo "    reverse_proxy https://qyapi.weixin.qq.com {" >> /etc/caddy/Caddyfile
echo "        header_up Host {upstream_hostport}" >> /etc/caddy/Caddyfile
echo "    }" >> /etc/caddy/Caddyfile
echo "}" >> /etc/caddy/Caddyfile

# 启动 Caddy
echo "启动 Caddy..."
systemctl enable caddy --now

echo "Caddy微信代理，安装完成！"

# 返回结果
if [ "$port" == "80" ]; then
    echo "您的代理接口为 http://${domain} 或 http://${ip_address}"
else
    echo "您的代理接口为 http://${domain}:${port} 或 http://${ip_address}:${port}"
fi
