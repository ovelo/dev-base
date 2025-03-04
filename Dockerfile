FROM ubuntu:latest
LABEL maintainer="ovelo"

ENV DEBIAN_FRONTEND=noninteractive
RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list \
    && sed -i 's@//.*security.ubuntu.com@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y openssh-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 创建 SSH 目录并设置权限
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

# 硬编码默认公钥（替换为你自己的公钥）
RUN echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEHKfTG5absuTi+thB9ZhiH793XxLFCj0p0+XF+dXYDf ovelo" > /root/.ssh/authorized_keys

# 支持动态添加其他公钥
ARG ADDITIONAL_SSH_KEYS
RUN if [ -n "$ADDITIONAL_SSH_KEYS" ]; then \
      echo "$ADDITIONAL_SSH_KEYS" | tr ',' '\n' >> /root/.ssh/authorized_keys; \
    fi && chmod 600 /root/.ssh/authorized_keys
# 配置 SSH 服务，禁用密码登录
RUN mkdir /var/run/sshd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    && sed -i '$a AuthorizedKeysFile .ssh/authorized_keys' /etc/ssh/sshd_config
WORKDIR /20zhaiyilin
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
