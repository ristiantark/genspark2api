#!/bin/bash

# 注册 Warp（如果需要）
warp-cli register

# 连接 Warp
warp-cli connect

# 等待连接完成
while ! warp-cli status | grep -q "Connected"; do
    sleep 1
done

# 设置 Warp 为代理模式（如果需要）
warp-cli set-mode proxy

# 确保全局流量走 Warp
ip route add default dev cloudfared

echo "Warp configured and connected"
