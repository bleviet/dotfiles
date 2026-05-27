ARG BASE_IMAGE=ubuntu:latest
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

# Install fundamental system tooling based on package manager
RUN if command -v apt-get >/dev/null 2>&1; then \
      apt-get update && apt-get install -y \
      sudo bash tzdata locales && \
      ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
      echo $TZ > /etc/timezone && \
      dpkg-reconfigure --frontend noninteractive tzdata && \
      locale-gen en_US.UTF-8 && \
      rm -rf /var/lib/apt/lists/*; \
    elif command -v dnf >/dev/null 2>&1; then \
      dnf clean all && dnf install -y \
      sudo bash tzdata glibc-langpack-en && \
      ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
      echo $TZ > /etc/timezone; \
    fi

# Create test user
RUN useradd -m -s /bin/bash user && \
    echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

ENV GIT_USER_NAME="Test User"
ENV GIT_USER_EMAIL="test@example.com"
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

USER user
WORKDIR /home/user/dotfiles

# Copy current dotfiles layout
COPY --chown=user:user core /home/user/dotfiles/core
COPY --chown=user:user os /home/user/dotfiles/os
COPY --chown=user:user host /home/user/dotfiles/host
COPY --chown=user:user scripts /home/user/dotfiles/scripts
COPY --chown=user:user bootstrap.sh /home/user/dotfiles/bootstrap.sh
COPY --chown=user:user install.sh /home/user/dotfiles/install.sh

# Run the bootstrap script non-interactively
RUN ./bootstrap.sh