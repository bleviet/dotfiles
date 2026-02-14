ARG BASE_IMAGE=ubuntu:latest
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

RUN apt-get update && apt-get install -y \
    sudo \
    bash \
    tzdata \
    locales && \
    ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8

RUN useradd -m -s /bin/bash user && \
    echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

ENV GIT_USER_NAME="USER"
ENV GIT_USER_EMAIL="user@example.com"

USER user

COPY --chown=user:user scripts /home/user/dotfiles/scripts
COPY --chown=user:user stow /home/user/dotfiles/stow
COPY --chown=user:user setup /home/user/dotfiles/setup

WORKDIR /home/user/dotfiles

RUN yes | bash setup