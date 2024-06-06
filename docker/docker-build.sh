#!/usr/bin/env bash

set -eux

fine_builder=${fine_builder-"fine_builder"}

exist_fine_builder=$(docker buildx ls | grep "fine_builder")

if [ -z "$exist_fine_builder" ]; then
  echo "create a buildx instance $fine_builder"
  docker buildx create --name $fine_builder --driver docker-container
else
  echo "using exist buildx instance $fine_builder"
fi

target_project=${target_project-"yaohwu"}

# 使用 --platform 交叉构建出跨平台的多个镜像
# 使用 -t 指定 tag，跨平台共享一个tag；会在 pull 时使用本机的架构 pull 到对应的镜像，如果没有匹配的，则会直接拋错
# 使用 --push 直接推送，buildx 不会 export 出对应 tag 的多个镜像
docker buildx build --builder $fine_builder --no-cache --platform linux/amd64,linux/arm64 -t "$target_project"/debian:bookworm-slim --push .

echo "docker build debian image end"
