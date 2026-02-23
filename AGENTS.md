# devwork Technical Guide

A reusable Node.js development container base image with modern tooling and shell configuration. Built for VSCode devcontainers, GitHub Codespaces, and Coder.com.

## Core Principles

**Single Responsibility**: Provide a consistent Node.js development environment with modern tooling and shell configuration.

**Reusability**: Generic base image usable across projects. Project-specific configuration (services, volumes, extensions) stays in project repos.

**Version Flexibility**: pnpm version is project-controlled via `packageManager` field in package.json. Corepack automatically downloads and uses the specified version.

**Multi-Platform**: Builds for both amd64 and arm64 architectures for broad compatibility.

## Architecture Decisions

### Base Image Strategy

Uses official Node.js Debian images (not Alpine) for better compatibility with native modules and standard tooling. The `ARG NODE_VERSION` allows building multiple Node.js versions from a single Dockerfile.

### User Model

Runs as the `node` user (non-root) provided by the official Node.js image. System-wide tools are installed as root, user-specific tools (Oh My Zsh, plugins, uv, OpenCode) are installed after switching to the node user.

### Shell Configuration Pattern

**Three-tier config:**

- `.profile` - Shared configuration (PATH, aliases, functions) loaded by all shells
- `.zshrc` - zsh-specific (Oh My Zsh, Starship, loads .profile)
- `.bashrc` - Appended (not replaced) to load .profile, preserving base image defaults

**Why this pattern:**

- Single source of truth for shared config
- Preserves base image configurations
- Works with both bash and zsh
- Easy to extend or override

### Git Configuration Strategy

Git defaults are in `/etc/gitconfig` (system-level), not `~/.gitconfig`. This allows users to mount their personal config to `~/.gitconfig` without losing the defaults. Git merges both configs with user settings taking precedence.

**Included defaults:**

- Pull with rebase
- Auto-setup remote on push
- GPG signing disabled by default
- Optimized rebase, log, and diff settings

See `.gitconfig` for complete list.

### Tool Installation Locations

**System-wide** (installed as root, available to all users):

- Starship: Installed via official script to system bin
- System packages: Via apt-get
- pnpm: Via Corepack (system-wide)
- Version check: `/usr/local/bin/devwork-versions`

**User-specific** (installed as node user):

- uv/uvx: `~/.cargo/bin/`
- OpenCode: `~/.opencode/bin/`
- Oh My Zsh: `~/.oh-my-zsh/`
- Plugins: `~/.oh-my-zsh/custom/plugins/`

**PATH setup:**

- `PNPM_HOME` in Dockerfile ENV
- User bins (`~/.cargo/bin`, `~/.opencode/bin`) in Dockerfile ENV
- Additional paths in `.profile` for completeness

### Build Process

**Multi-version builds:**
The workflow builds three variants using a matrix strategy. See `.github/workflows/build.yml` for the current matrix and tag strategy.

**Caching:**
Registry-based caching is used per Node version for faster rebuilds. Cache keys are based on the Node version to avoid cross-version pollution.

**Testing:**
All builds are tested using the `devwork-versions` script which verifies all tools are installed and accessible. This same script can be used as a healthcheck in projects.

### Tagging Strategy

Tags follow the pattern `{NODE_VERSION}-node` for stable tags and `{NODE_VERSION}-node-{GIT_SHA}` for commit-specific tags. The `-node` suffix allows future language variants (e.g., `-rust`, `-go`, `-polyglot`).

See the workflow file for the exact metadata-action configuration.

## Project Structure

**Configuration files:**

- `Dockerfile` - Image build definition with ARG for Node version
- `.profile` - Shared shell configuration
- `.zshrc` - zsh-specific configuration
- `.gitconfig` - System-level Git defaults
- `devwork-versions` - Version verification script

**Build automation:**

- `.github/workflows/build.yml` - Multi-version build, test, and publish
- `.github/dependabot.yml` - Weekly dependency updates

**Documentation:**

- `README.md` - User-facing documentation and usage examples
- `CLAUDE.md` - This file (technical reference)

## Development Patterns

### Adding New Tools

**System-wide tools:**
Add to the apt-get install list in the Dockerfile or install via curl as root before the `USER node` line.

**User-specific tools:**
Install after `USER node`. If the tool installs to a non-standard location, add the bin directory to the PATH ENV or to `.profile`.

### Updating Shell Configuration

**Shared config (aliases, functions, PATH):**
Edit `.profile` - affects both bash and zsh.

**zsh-specific config:**
Edit `.zshrc` - only affects zsh users.

**Important:** Don't replace `.bashrc`, append to it. The base image may have important bash-specific configuration.

### Version Verification

The `devwork-versions` script serves multiple purposes:

- CI testing (ensures all tools are installed)
- Manual verification (users can run it to check their environment)
- Healthcheck (can be used in docker-compose healthcheck configuration)
- Documentation (shows what tools are expected)

When adding new tools, update this script to include them in verification.

### Build Triggers

Builds are triggered on:

- Pushes to main that modify build-related files (see workflow paths filter)
- Weekly schedule for security updates
- Manual dispatch for on-demand builds

The weekly rebuild ensures the image includes the latest security patches from the base image and updated Oh My Zsh plugins, even if the Dockerfile hasn't changed.

## Usage in Projects

Projects should reference the image in their `devcontainer.json` or `docker-compose.yml` and add project-specific configuration:

- Services (databases, caches, queues)
- Volume mounts (workspace, persistent data)
- VSCode extensions
- Environment variables
- Port forwarding

The base image provides the development environment. Projects add their specific requirements on top.

## Contributing

**Testing changes locally:**
Build the image locally with the desired Node version (see README for build commands) and run `devwork-versions` to verify all tools are installed.

**Before pushing:**
Ensure all configuration files that are copied in the Dockerfile exist in the repo and are properly formatted.

**CI will:**

- Build for all Node versions in the matrix
- Test using `devwork-versions`
- Push to registry if tests pass
- Tag appropriately based on metadata action configuration

## Security Considerations

**Non-root user:**
The container runs as the `node` user (UID 1000) to avoid permission issues with mounted volumes and follow security best practices.

**Read-only Git config:**
When users mount their gitconfig, it should be read-only to prevent accidental modifications.

**GPG signing:**
Git is configured to sign commits, but GPG keys must be mounted separately by the project. The base image doesn't include or assume GPG key availability.

## Maintenance

**Weekly rebuilds:**
Automated weekly builds ensure the image stays current with security patches and Oh My Zsh plugin updates.

**Dependabot:**
Monitors base image updates and GitHub Actions versions. Review and merge dependabot PRs to keep dependencies current.

**Node version support:**
The matrix in the build workflow defines which Node versions are supported. Update the matrix when Node versions reach EOL or when new LTS versions are released.
