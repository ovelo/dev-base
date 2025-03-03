FROM ubuntu:latest
LABEL maintainer="ovelo"

# 安装 SSH 工具
RUN apt-get update && apt-get install -y openssh-client

# 创建 SSH 目录并设置权限
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

# 硬编码默认公钥（替换为你自己的公钥）
RUN echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEHKfTG5absuTi+thB9ZhiH793XxLFCj0p0+XF+dXYDf ovelo" > /root/.ssh/authorized_keys

# 支持动态添加其他公钥
ARG ADDITIONAL_SSH_KEYS
RUN if [ -n "$ADDITIONAL_SSH_KEYS" ]; then \
      echo "$ADDITIONAL_SSH_KEYS" | tr ',' '\n' >> /root/.ssh/authorized_keys; \
    fi && chmod 600 /root/.ssh/authorized_keys

CMD ["bash", "-c", "cat /root/.ssh/authorized_keys && echo 'SSH keys loaded'"]
