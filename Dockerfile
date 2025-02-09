# Stage 1: 构建阶段，使用 Golang 镜像构建二进制文件
FROM golang:1.20 AS builder

# 设置环境变量
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOFLAGS=-v

# 设置工作目录
WORKDIR /build

# 先复制 go.mod 和 go.sum 下载依赖
COPY go.mod go.sum ./
RUN go mod download -x

# 复制所有源码并构建生成可执行文件
COPY . .
RUN go build -v -x -o /genspark2api

# Stage 2: 最终镜像，使用 Debian 作为运行环境
FROM debian:bullseye-slim

# 安装应用运行时依赖及 Warp 客户端所需工具
RUN apt-get update && apt-get install -y \
    ca-certificates \
    tzdata \
    curl \
    iptables \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# 安装 Cloudflare Warp 客户端
RUN curl https://pkg.cloudflareclient.com/pubkey.gpg | apt-key add - && \
    echo "deb http://pkg.cloudflareclient.com/ bullseye main" | tee /etc/apt/sources.list.d/cloudflare-client.list && \
    apt-get update && apt-get install -y cloudflare-warp && \
    rm -rf /var/lib/apt/lists/*

# 将 warp 脚本复制到镜像中，并赋予执行权限
COPY warp.sh /usr/local/bin/warp.sh
RUN chmod +x /usr/local/bin/warp.sh

# 将启动入口脚本复制到镜像中，并赋予执行权限
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# 从构建阶段复制生成的应用二进制文件
COPY --from=builder /genspark2api /genspark2api

# 暴露应用端口
EXPOSE 7055

# 如有需要，可设置工作目录（例如你的应用在 /app/genspark2api/data 下读取数据）
WORKDIR /app/genspark2api/data

# 设置容器启动入口为启动脚本
ENTRYPOINT ["/usr/local/bin/start.sh"]
