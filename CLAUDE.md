# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a VS Code Dev Container configuration that creates a multi-language development environment based on Debian Trixie. The container runs as user `dev` (configurable via `USERNAME` build arg) with passwordless sudo and uses zsh as the default shell.

## Build Command

```bash
./build.sh
```

This builds the Docker image tagged as `devcontainer-dev:latest`.

Do not run Docker image builds locally when troubleshooting CI failures. Commit and push the fix, then use the GitHub Actions build as the validation check.

## Architecture

- **Dockerfile**: Defines the Debian Trixie base, native packages, compiler and document toolchains, the `dev` user, and the persistent-tool environment. The username/groupname are configurable via `USERNAME`/`GROUPNAME` build args (default: `dev`).
- **sky-tools**: Installs and updates frequently changing developer tools in the user's persistent home directory. GitHub CLI release archives are verified against GitHub's published SHA-256 checksums before installation.
- **example/.devcontainer/**: A ready-to-copy `.devcontainer` directory for new projects. Contains `devcontainer.json` (VS Code Dev Container config using `ghcr.io/sky87/skydevcontainer:latest` with a Docker volume for `/home/dev`) and `post-create.sh` (auto-installs project dependencies via bun, uv, cargo, dotnet).
- **zshrc**: System zshrc copied to `/etc/zsh/zshrc` that sets up PATH and sources nvm/fzf.

## Tool Locations

| Tool | Location |
|------|----------|
| Rust/Cargo | `~/.cargo/bin` |
| uv (Python) | `~/.local/bin` |
| nvm/Node.js | `~/.nvm` with command links in `~/.local/bin` |
| pnpm global binaries | `~/.local/share/pnpm` |
| .NET | `~/.dotnet` |
| fzf | `~/.fzf` |
| GitHub CLI | `~/.local/bin/gh` |
| opam/OCaml | `~/.local/bin/opam` and `~/.opam` |
| elan/Lean | `~/.elan` |
| Claude Code | `~/.local/bin/claude` |
| Codex | `~/.local/bin/codex` |
| Bun | `~/.bun` |
| pi | `~/.local/share/pnpm` |

## Documentation Maintenance

When making changes to this project, keep the documentation up to date:

- **CLAUDE.md**: Update when adding/removing tools, changing build processes, or modifying architecture. Keep the tool locations table current.
- **README.md**: Update when adding/removing toolchains, changing usage instructions, or modifying VS Code extensions.
