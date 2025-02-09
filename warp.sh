#!/bin/sh
set -e

echo "启动 Cloudflare Warp 客户端..."

# 检查 Warp 是否已注册；若未注册则执行注册
if ! warp-cli status | grep -q "Registered"; then
  echo "未注册，开始注册 Warp..."
  warp-cli register
fi

# 检查 Warp 是否已连接；若未连接则尝试连接
if ! warp-cli status | grep -q "Connected"; then
  echo "未连接，开始连接 Warp..."
  warp-cli connect
fi

echo "Warp 客户端已启动，所有流量将通过 Warp 转发。"
