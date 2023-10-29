#!/bin/bash

# 检测Caddy是否已安装
if ! command -v caddy &> /dev/null; then
    echo "Caddy未被正确安装，请检查网络并重新安装Caddy。"
    exit 1
fi

echo "Caddy已安装，继续配置微信代理..."

# 创建 /etc/caddy/vhost 目录
mkdir -p /etc/caddy/vhost

# 创建 /etc/caddy/vhost/wechat.conf 文件
touch /etc/caddy/vhost/wechat.conf


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
echo "正在将微信代理配置写入 Caddyfile..."
cat <<EOF >/etc/caddy/vhost/wechat.conf
EOF

if [ "$use_domain" == "y" ]; then
    echo "${domain}:${port} {" >> /etc/caddy/vhost/wechat.conf
else
    echo ":${port} {" >> /etc/caddy/vhost/wechat.conf
fi

echo "    reverse_proxy https://qyapi.weixin.qq.com {" >> /etc/caddy/vhost/wechat.conf
echo "        header_up Host {upstream_hostport}" >> /etc/caddy/vhost/wechat.conf
echo "    }" >> /etc/caddy/vhost/wechat.conf
echo "}" >> /etc/caddy/vhost/wechat.conf

cat <<EOF >>/etc/caddy/Caddyfile
{
    import /etc/caddy/vhost/*.conf
}
EOF

# 启动 Caddy
echo "启动 Caddy..."
systemctl enable caddy --now

echo "Caddy微信代理，安装完成！"

# 返回结果
if [ "$use_domain" == "y" ]; then
    echo "您的代理接口为 http://${domain}:${port}"
else
    echo "您的代理接口为 http://${ip_address}:${port}"
fi
