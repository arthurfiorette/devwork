# Node.js Development Container

A production-ready Node.js development container image with zsh, Oh My Zsh, Starship prompt, and essential development tools. Designed for VSCode devcontainers, GitHub Codespaces, and Coder.com.

## What's Included

### Base Environment

- Node.js (Debian Trixie Slim base)
- pnpm package manager (latest via Corepack)
- GitHub CLI
- Python 3, make, g++, build-essential

### Modern CLI Tools

- ripgrep (rg) - Fast grep alternative for code search
- jq - JSON processor for API responses and config files

### Shell Configuration

- zsh with Oh My Zsh
- Starship prompt
- Oh My Zsh plugins: autoupdate, z, git, docker, docker-compose, npm, node, zsh-autosuggestions, fast-syntax-highlighting, zsh-autocomplete, gh
- Persistent shell history support

### Developer Tools

- Claude Code CLI for AI-assisted development
- uv/uvx (Python package runner for AI tools like Serena MCP)
- OpenSSL development libraries (for Prisma and other native modules)
- Git with optimized configuration
- Build tools for native Node.js modules

## Usage

### Complete Example

See `example.devcontainer.json` for a full configuration example including:

- Docker-in-Docker support (with moby: false for Trixie compatibility)
- Persistent volumes for shell history and pnpm store
- Git, SSH, and GPG key mounting
- Common VSCode extensions
- Port forwarding example

### In devcontainer.json

```json
{
  "image": "ghcr.io/arthurfiorette/devwork:lts-node",
  "customizations": {
    "vscode": {
      "settings": {
        "terminal.integrated.defaultProfile.linux": "zsh"
      }
    }
  }
}
```

### With Docker Compose

```yaml
services:
  devcontainer:
    image: ghcr.io/arthurfiorette/devwork:lts-node
    volumes:
      - .:/workspace
    command: sleep infinity
```

### Direct Docker Run

```bash
docker run -it --rm ghcr.io/arthurfiorette/devwork:lts-node zsh
```

## Available Tags

The image is published with tags for different Node.js versions:

- `lts-node` - Node.js LTS version
- `lts-node-abc1234` - Node.js LTS at specific commit

- `24-node` - Node.js 24.x (recommended)
- `24-node-abc1234` - Node.js 24.x at specific commit
- `22-node` - Node.js 22.x
- `22-node-abc1234` - Node.js 22.x at specific commit

Use version tags (e.g., `lts-node`) for the latest build, or commit-specific tags (e.g., `lts-node-abc1234`) to pin to a specific version. Images are rebuilt weekly with security updates.

## Features

### Shell Experience

- zsh as default shell with persistent history
- Starship prompt with Node.js, git, and Docker awareness
- Oh My Zsh with curated plugins for Node.js development
- Syntax highlighting and autosuggestions
- Git integration showing branch, status, and changes

### Development Optimized

- Pre-installed build tools for native modules
- pnpm configured and ready (no interactive prompts)
- Proper permissions for non-root user
- Optimized for monorepos and workspaces
- Fast code search with ripgrep
- JSON processing with jq

### AI Development Ready

- uv/uvx installed for running AI coding assistants
- Compatible with Serena MCP, Cursor, and other AI tools
- Supports GitHub Codespaces natively
- Ready for Claude Code, Aider, and similar tools

## Configuration

### Persistent Shell History

Mount a volume to preserve shell history across container rebuilds:

```json
"mounts": [
  "source=shell-history,target=/home/node/shell-history,type=volume"
]
```

### Persistent pnpm Store

Mount a volume for faster package installations:

```json
"mounts": [
  "source=pnpm-store,target=/home/node/.local/share/pnpm/store,type=volume"
]
```

### Git Configuration

The image includes optimized Git defaults (rebase on pull, auto-setup remote, etc.).

To use your own Git config (recommended for personal settings like name/email):

```json
"mounts": [
  "source=${localEnv:HOME}/.gitconfig,target=/home/node/.gitconfig,type=bind,readonly"
]
```

Your personal config will be merged with the built-in defaults (your settings take precedence).

If not mounted, the container uses the included defaults:

- Pull with rebase
- Auto-setup remote on push
- GPG signing enabled (requires GPG keys mounted separately)
- Optimized log, diff, and rebase settings

### User Password

The `node` user has a default password of `node`. To change it:

```bash
sudo passwd node
```

Note: the password resets to `node` on every container rebuild.

## Built-in Shell Helpers

### pnpm Aliases

- `p` - Shorthand for pnpm
- `pw` - Run command in workspace root (pnpm run --workspace-root)

### Git Workflow Functions

- `wip` - Quick commit all changes, pull with rebase, and push
- `wipf` - Same as wip but skips git hooks (use with caution)

### Utility Functions

- `notty` - Run command without TTY (strips ANSI colors, useful for piping to files)

## Version Strategy

The image uses pnpm@latest, but Corepack automatically respects the `packageManager` field in your project's package.json. If your project specifies pnpm@9.15.9, Corepack will download and use that version automatically. This allows the same base image to work with different pnpm versions across projects.

## Building Locally

```bash
# Build for Node.js 24
docker build -t my-devcontainer:24-node .

# Build for Node.js 22
docker build --build-arg NODE_VERSION=22 -t my-devcontainer:22-node .

# Build for Node.js 20
docker build --build-arg NODE_VERSION=20 -t my-devcontainer:20 .

# Build for LTS
docker build --build-arg NODE_VERSION=lts -t my-devcontainer:lts-node .

# Test the build
docker run --rm my-devcontainer:24-node devwork-versions
```

## Requirements

- Docker Desktop or Docker Engine
- VSCode with Dev Containers extension (for devcontainer usage)
- At least 2GB disk space for the image

## Contributing

This is a personal project but issues and suggestions are welcome. The image is rebuilt weekly with the latest security updates and Oh My Zsh plugins.

## License

MIT License - See LICENSE file for details.

## Verification

The image includes a `devwork-versions` command to verify all tools are installed:

```bash
# Run inside container
devwork-versions

# Or from outside
docker run --rm ghcr.io/arthurfiorette/devwork:24-node devwork-versions
```

This script can also be used as a healthcheck in docker-compose:

```yaml
healthcheck:
  test: ['CMD', 'devwork-versions']
  interval: 30s
  timeout: 3s
```
