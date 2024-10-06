FROM debian:latest

# Set environment variable for non-interactive installations
ENV DEBIAN_FRONTEND=noninteractive

# Set timezone to Europe/Berlin (required for nodejs installation)
ENV TZ=Europe/Berlin

# Install necessary packages
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

# Add a non-root user with sudo privileges
RUN useradd -m -s /bin/bash user && \
    echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Set environment variables for git configuration
# to test setup_gitconfig.sh
ENV GIT_USER_NAME="USER"
ENV GIT_USER_EMAIL="user@example.com"

# Set the user to non-root
USER user

# Copy files to the user's home directory
COPY --chown=user:user scripts /home/user/dotfiles/scripts
COPY --chown=user:user stow /home/user/dotfiles/stow
COPY --chown=user:user setup_env.sh /home/user/dotfiles/setup_env.sh

# Set the working directory
WORKDIR /home/user/dotfiles

# Run the setup script as the non-root user
RUN yes | bash setup_env.sh

