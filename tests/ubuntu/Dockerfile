FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
  sudo \
  bash \
  && rm -rf /var/lib/apt/lists/*

COPY scripts /dotfiles/scripts
COPY stow /dotfiles/stow
COPY setup_env.sh /dotfiles/setup_env.sh

WORKDIR /dotfiles

