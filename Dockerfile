FROM kalilinux/kali-rolling

# prevent interactive prompts
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y \
    openssh-server \
    kali-linux-headless \
    net-tools \
    iputils-ping \
    nano \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd

# generate host keys it prevents crash on startup
RUN ssh-keygen -A

# configure SSH root login
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Enable Legacy Encryption for Guacamole
# This allows the Kali SSH server to talk to the Guacamole client
RUN echo 'HostKeyAlgorithms +ssh-rsa' >> /etc/ssh/sshd_config && \
    echo 'PubkeyAcceptedKeyTypes +ssh-rsa' >> /etc/ssh/sshd_config

RUN echo 'root:root' | chpasswd

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]