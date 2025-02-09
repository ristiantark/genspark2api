# 使用 Golang 镜像作为构建阶段
FROM golang AS builder
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux
WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o /genspark2api

# 使用 Ubuntu 作为最终镜像
FROM ubuntu:20.04

# 安装必要的工具和 Warp 客户端
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    tzdata \
    gnupg \
    iproute2 \
    && curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ focal main" | tee /etc/apt/sources.list.d/cloudflare-client.list \
    && apt-get update \
    && apt-get install -y cloudflare-warp \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 复制应用程序
COPY --from=builder /genspark2api /app/genspark2api

# 添加 Warp 配置脚本
COPY warp-config.sh /app/warp-config.sh
RUN chmod +x /app/warp-config.sh

# 创建挂载点
RUN mkdir -p /app/genspark2api/data

# 暴露端口
EXPOSE 7055

# 设置工作目录
WORKDIR /app/genspark2api

# 设置启动命令
CMD ["/bin/bash", "-c", "/app/warp-config.sh && /app/genspark2api"]
