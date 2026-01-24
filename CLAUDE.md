# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a VS Code Dev Container configuration that creates a multi-language development environment based on Debian Trixie. The container runs as user `sky` with passwordless sudo and uses zsh as the default shell.

## Build Command

```bash
./build.sh
```

This builds the Docker image tagged as `devcontainer-sky:latest`.

## Architecture

- **Dockerfile**: Defines the container with Clang/C++, Rust, Python, Node.js, Bun, .NET, and LaTeX toolchains. All tools are installed to `/opt/` with sky ownership to allow self-updates.
- **devcontainer.json**: VS Code Dev Container configuration using the published image from `ghcr.io/sky87/skydevcontainer:latest`. Uses a Docker volume (`sky-home`) to persist `/home/sky`.
- **post-create.sh**: Optional script that runs after container creation to auto-install project dependencies (bun, uv, cargo, dotnet).
- **zshrc**: System zshrc copied to `/etc/zsh/zshrc` that sets up PATH and sources nvm/fzf.

## Tool Locations

| Tool | Location |
|------|----------|
| Rust/Cargo | `/opt/rust/cargo/bin` |
| uv (Python) | `/opt/uv` |
| nvm/Node.js | `/opt/nvm` |
| .NET | `/opt/dotnet` |
| fzf | `/opt/fzf` |
| Claude Code | `/opt/claude-code` |
| Bun | `/opt/bun` |

## Documentation Maintenance

When making changes to this project, keep the documentation up to date:

- **CLAUDE.md**: Update when adding/removing tools, changing build processes, or modifying architecture. Keep the tool locations table current.
- **README.md**: Update when adding/removing toolchains, changing usage instructions, or modifying VS Code extensions.
