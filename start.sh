#!/bin/sh
set -e

echo "先后台启动 warp 脚本..."
/usr/local/bin/warp.sh &

# 可根据实际情况等待几秒钟，以确保 Warp 连接成功
sleep 5

echo "启动 genspark2api 应用..."
exec /genspark2api
