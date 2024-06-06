FROM debian:bookworm-20240423-slim

LABEL name="debian-bookworm-slim" version="1.0" author="yaohwu"

# 非交互式
ENV DEBIAN_FRONTEND noninteractive

# 使用 TARGETPLATFORM 控制跨平台时不同的二进制内容拷贝
ARG TARGETPLATFORM
COPY resources/${TARGETPLATFORM}/a.txt /etc/apt/a.txt

RUN set -eux; \
    echo "target platform ${TARGETPLATFORM}"; \
    cat /etc/apt/a.txt; \
    echo "done"

# 替换软件源为 aliyun
RUN set -eux; \
    echo "${TARGETPLATFORM} demo"; \
    rm -v /etc/apt/sources.list.d/*
COPY resources/http.sources.list /etc/apt/sources.list

# 先用 http 软件源安装 ca-certificates,让 apt 支持 https 的软件源
RUN apt-get clean \
    && apt-get update  \
    && apt-get install -y ca-certificates --fix-missing
# 替换软件源为 aliyun
COPY resources/sources.list /etc/apt/sources.list
RUN apt-get clean \
    && apt-get update  \
    # && apt-get upgrade -y  \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/bash"]

