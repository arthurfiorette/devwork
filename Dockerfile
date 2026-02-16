# Node.js Development Container
# Multi-version support via build arg
ARG NODE_VERSION=24
FROM node:${NODE_VERSION}-bookworm-slim

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
        libssl-dev \
        python3 \
        make \
        g++ \
        build-essential \
        ripgrep \
        jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Starship prompt
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes

# Install uv/uvx (Python package runner for AI tools)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Enable pnpm (latest - projects specify version via packageManager field)
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable && \
    corepack prepare pnpm@latest --activate

# Switch to node user for user-specific installations
USER node
WORKDIR /home/node

# Add cargo bin to PATH globally (for uv/uvx)
ENV PATH="/home/node/.cargo/bin:$PATH"

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
