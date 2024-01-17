#!/bin/bash

# 询问用户输入服务器IP地址
read -p "请输入服务器IP地址 (WG_HOST): " SERVER_IP

# 询问用户输入管理员密码
read -p "请输入管理员密码 (PASSWORD): " ADMIN_PASSWORD

# 询问用户输入wg-easy数据保存目录
read -p "请输入wg-easy数据保存目录路径 (例如: ~/.wg-easy): " DATA_DIR

# 检查目录是否存在，如果不存在则创建
if [ ! -d "$DATA_DIR" ]; then
  mkdir -p "$DATA_DIR"
  echo "已创建目录: $DATA_DIR"
fi

# 构建docker命令
DOCKER_COMMAND="docker run -d \
  --name=wg-easy \
  -e WG_HOST=${SERVER_IP} \
  -e PASSWORD=${ADMIN_PASSWORD} \
  -v ${DATA_DIR}:/etc/wireguard \
  -p 51820:51820/udp \
  -p 51821:51821/tcp \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  --sysctl=\"net.ipv4.conf.all.src_valid_mark=1\" \
  --sysctl=\"net.ipv4.ip_forward=1\" \
  --restart unless-stopped \
  ghcr.io/wg-easy/wg-easy"

# 执行docker命令
eval $DOCKER_COMMAND

echo "wg-easy容器已经成功启动！"
