#!/usr/bin/env bash

plan="$1"
app_name_suffix="$2"
multi_plan="multi"
single_merged_plan="single"
plan=${plan:-"$multi_plan"}
app_name_suffix=${app_name_suffix:-"app"}

config_file_folder="/Users/yaohwu/buildx/config"

echo "using plan [$plan] to build docker image, supported plans: [$multi_plan,$single_merged_plan]"

set -eux

fine_builder=${fine_builder-"fine_builder"}

set +e
exist_fine_builder=$(docker buildx ls | grep "fine_builder")

if [ -z "$exist_fine_builder" ]; then
  echo "create a buildx instance $fine_builder"
  mkdir -p $config_file_folder
  cp buildkitd.toml $config_file_folder/buildkitd.toml
  cat $config_file_folder/buildkitd.toml
  docker buildx create --name $fine_builder --driver docker-container --config $config_file_folder/buildkitd.toml
else
  echo "using exist buildx instance $fine_builder"
fi
set -e

target_project=${target_project-"yaohwu"}

echo "using $plan plan to build docker image docker build [debian$app_name_suffix] image end"

if [ "$plan" == "$multi_plan" ]; then
  # 使用 --platform 交叉构建出跨平台的多个镜像
  # 使用 -t 指定 tag，跨平台共享一个tag；会在 pull 时使用本机的架构 pull 到对应的镜像，如果没有匹配的，则会直接拋错
  # 使用 --push 直接推送，buildx 不会 export 出对应 tag 的多个镜像
  docker buildx build --builder $fine_builder --platform linux/amd64,linux/arm64 -t "$target_project"/debian"$app_name_suffix":bookworm-slim --push .

elif
  [ "$plan" == "$single_merged_plan" ]
then
  # amd64
  docker buildx build --builder $fine_builder --platform linux/amd64 -t "$target_project"/debian"$app_name_suffix":bookworm-slim-amd64 --load .
  docker push "$target_project"/debian"$app_name_suffix":bookworm-slim-amd64
  # arm64
  docker buildx build --builder $fine_builder --platform linux/arm64 -t "$target_project"/debian"$app_name_suffix":bookworm-slim-arm64 --load .
  docker push "$target_project"/debian"$app_name_suffix":bookworm-slim-arm64

  # 创建和维护清单文件
  docker manifest create "$target_project"/debian"$app_name_suffix":bookworm-slim \
    --amend "$target_project"/debian"$app_name_suffix":bookworm-slim-amd64 \
    --amend "$target_project"/debian"$app_name_suffix":bookworm-slim-arm64
  echo "docker single manifest created"

  # 推送 multi-architecture 镜像
  docker manifest push "$target_project"/debian"$app_name_suffix":bookworm-slim
fi
echo "docker build [debian$app_name_suffix] image end"
