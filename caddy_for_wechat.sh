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

# 检测Caddy是否已安装
if ! command -v caddy &> /dev/null; then
    echo "Caddy未被正确安装,请检查网络并重新安装Caddy。"
    exit 1
fi

echo "Caddy已安装,继续配置代理..."

# 获取用户输入
read -p "请选择要代理的应用(1:微信 2:Telegram 3:其他): " app

# 根据选择生成配置
if [ "$app" == "1" ]; then
  filename="wechat"
  proxy_url="https://qyapi.weixin.qq.com"
elif [ "$app" == "2" ]; then
  filename="telegram"
  proxy_url="https://api.telegram.org"  
elif [ "$app" == "3" ]; then
  read -p "请输入代理名称:" filename
  read -p "请输入接口地址:" proxy_url
fi

read -p "是否使用域名?(y/n): " use_domain

if [ "$use_domain" == "y" ]; then
  read -p "请输入您的域名: " domain
else
  ip_address=$(curl -sS ipinfo.io/ip)  
fi

# 获取端口号
read -p "请输入端口号: " port
port=${port:-80}

# 生成对应的Caddyfile配置文件
mkdir -p /etc/caddy/vhost  
touch /etc/caddy/vhost/${filename}.conf

# 写入配置
cat <<EOF > /etc/caddy/vhost/${filename}.conf
${domain}:${port} {
   reverse_proxy ${proxy_url} {
        header_up Host {upstream_hostport}
   }
}
EOF

# 导入配置
cat <<EOF >>/etc/caddy/Caddyfile
{
   import /etc/caddy/vhost/${filename}.conf
}
EOF

# 启动Caddy
systemctl enable caddy --now

# 返回结果
if [ "$use_domain" == "y" ]; then
   echo "您选择的应用是${app},代理接口为 http://${domain}:${port}"
else
   echo "您选择的应用是${app},代理接口为 http://${ip_address}:${port}"
fi
