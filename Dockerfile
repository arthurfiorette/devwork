# Node.js Development Container
# Multi-version support via build arg
ARG NODE_VERSION=24
FROM node:${NODE_VERSION}-trixie-slim

# Install system dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        bash \
        zsh \
        git \
        openssh-client \
        openssl \
        ca-certificates \
        curl \
        wget \
        gnupg \
        sudo \
        locales \
        nano \
        libssl-dev \
        python3 \
        make \
        g++ \
        build-essential \
        ripgrep \
        jq \
        bat \
        eza \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Generate locale
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Setup sudo for node user
RUN echo "node ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/node && \
    chmod 0440 /etc/sudoers.d/node

# Setup NPM global directory with proper permissions
RUN umask 0002 && \
    groupadd -r npm && \
    usermod -a -G npm node && \
    mkdir -p /usr/local/share/npm-global && \
    chown :npm /usr/local/share/npm-global && \
    chmod g+s /usr/local/share/npm-global && \
    npm config set prefix /usr/local/share/npm-global
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=/usr/local/share/npm-global/bin:$PATH

# Copy Git defaults to system-level config
COPY .gitconfig /etc/gitconfig

# Copy version check script
COPY devwork-versions /usr/local/bin/devwork-versions
RUN chmod +x /usr/local/bin/devwork-versions

# Enable pnpm (latest - projects specify version via packageManager field)
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN corepack enable && \
    corepack prepare pnpm@latest --activate

# Switch to node user for user-specific installations
USER node
WORKDIR /home/node

# Add user bin directories to PATH
ENV PATH="/home/node/.cargo/bin:/home/node/.claude/bin:$PATH"

# Configure NPM global for node user
RUN npm config set prefix /usr/local/share/npm-global

# Install uv/uvx (Python package runner for AI tools)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Claude Code CLI
RUN curl -fsSL https://claude.ai/install.sh | bash

# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install Oh My Zsh custom plugins
RUN git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting && \
    git clone --depth=1 https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete && \
    git clone --depth=1 https://github.com/TamCore/autoupdate-oh-my-zsh-plugins.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/autoupdate

# Copy shell configurations
COPY --chown=node:node .profile /home/node/.profile
COPY --chown=node:node .zshrc /home/node/.zshrc

# Append .profile loading to .bashrc (don't overwrite existing)
RUN echo "" >> ~/.bashrc && \
    echo "# Load shared profile" >> ~/.bashrc && \
    echo "if [ -f ~/.profile ]; then" >> ~/.bashrc && \
    echo "    . ~/.profile" >> ~/.bashrc && \
    echo "fi" >> ~/.bashrc

# Git safe directory for mounted volumes
RUN git config --global --add safe.directory '*'

# Create necessary directories with proper ownership
RUN mkdir -p ~/shell-history \
    ~/.local/share/zsh \
    ~/.local/state/zsh-autocomplete/log \
    ~/.local/share/pnpm/store \
    && chown -R node:node ~/.local

# Set working directory
WORKDIR /workspace

# Metadata labels
LABEL org.opencontainers.image.source="https://github.com/arthurfiorette/devwork"
LABEL org.opencontainers.image.description="Node.js development container with zsh, Oh My Zsh, Starship, and essential dev tools"
LABEL org.opencontainers.image.licenses="MIT"
