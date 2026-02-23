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
        procps \
        sudo \
        starship \
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
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Generate locale
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV COLORTERM=truecolor

# Setup passwordless sudo for node user (devcontainer standard practice)
RUN echo "node ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/node && \
    chmod 0440 /etc/sudoers.d/node

# Set default password for node user (change with: sudo passwd node)
RUN echo "node:node" | chpasswd

# Copy Git defaults to system-level config
COPY .gitconfig /etc/gitconfig

# Copy version check script
COPY devwork-versions /usr/local/bin/devwork-versions
RUN chmod +x /usr/local/bin/devwork-versions

# Enable pnpm (latest - projects specify version via packageManager field)
ENV PNPM_HOME="/pnpm"
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN corepack enable && \
    corepack prepare pnpm@latest --activate

# Switch to node user for user-specific installations
USER node
WORKDIR /home/node
ENV HOME=/home/node

# Setup all PATH directories and NPM config in one place
ENV NPM_CONFIG_PREFIX="$HOME/.npm-global"
ENV PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.opencode/bin:$HOME/.npm-global/bin:$PNPM_HOME:$PATH"

# Configure NPM global for node user
RUN npm config set prefix "$HOME/.npm-global" && \
    mkdir -p "$HOME/.npm-global"

# Install uv/uvx (Python package runner for AI tools)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install OpenCode CLI
RUN curl -fsSL https://opencode.ai/install | bash

# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install Oh My Zsh custom plugins
ENV ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
RUN git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM}/plugins/zsh-autosuggestions && \
    git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/fast-syntax-highlighting && \
    git clone --depth=1 https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM}/plugins/zsh-autocomplete && \
    git clone --depth=1 https://github.com/TamCore/autoupdate-oh-my-zsh-plugins.git ${ZSH_CUSTOM}/plugins/autoupdate

# Copy shell configurations
COPY --chown=node:node .profile $HOME/.profile
COPY --chown=node:node .zshrc $HOME/.zshrc

# Copy Starship configuration
RUN mkdir -p $HOME/.config
COPY --chown=node:node starship.toml $HOME/.config/starship.toml

# Append .profile loading to .bashrc (don't overwrite existing)
RUN echo "" >> $HOME/.bashrc && \
    echo "# Load shared profile" >> $HOME/.bashrc && \
    echo "if [ -f ~/.profile ]; then" >> $HOME/.bashrc && \
    echo "    . ~/.profile" >> $HOME/.bashrc && \
    echo "fi" >> $HOME/.bashrc

# Git safe directory for mounted volumes
RUN git config --global --add safe.directory /workspace

# Create necessary directories with proper ownership
RUN mkdir -p $HOME/shell-history \
    $HOME/.local/share/zsh \
    $HOME/.local/state/zsh-autocomplete/log \
    $HOME/.local/share/pnpm/store \
    && chown -R node:node $HOME/.local

# Set working directory
WORKDIR /workspace

# Metadata labels
LABEL org.opencontainers.image.source="https://github.com/arthurfiorette/devwork"
LABEL org.opencontainers.image.description="Node.js development container with zsh, Oh My Zsh, Starship, and essential dev tools"
LABEL org.opencontainers.image.licenses="MIT"
