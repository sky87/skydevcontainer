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
- **skytools**: The standalone Go executable from https://github.com/sky87/skytools installs and updates developer tools in the persistent home. The Dockerfile's `skytools-release` stage downloads the architecture-specific public release, verifies `SHA256SUMS`, and copies it into the image. `SKYTOOLS_VERSION` selects the manager release (default `v0.3.0`). The bundled Bash implementation has been removed; `sky-tools` is a compatibility symlink.
- **System prerequisites**: Keep native packages aligned with `skytools deps`, which the Dockerfile runs as the target user. Set `SKY_TOOLS_DISABLE_OPAM_SANDBOX=1` explicitly because Docker provides isolation. Runtime versions come from upstream LTS/stable channels.
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
| Go toolchain | `~/.go/current`; workspace and installed commands in `~/go` |
| Amazon Corretto JDK | `~/.jdk/current` |
| fzf | `~/.fzf` |
| GitHub CLI | `~/.local/bin/gh` |
| btop | `~/.local/bin/btop` |
| opam/OCaml | `~/.local/bin/opam` and `~/.opam` |
| elan/Lean | `~/.elan` |
| Claude Code | `~/.local/bin/claude` |
| Codex | `~/.local/bin/codex` |
| OpenCode | `~/.opencode/bin/opencode` |
| Bun | `~/.bun` |
| pi | `~/.local/share/pnpm` |

## Documentation Maintenance

When making changes to this project, keep the documentation up to date:

Run application checks inside Docker. The `skytools-release` target can validate
the download independently of the large development image. Never run downloaded
executables or installers on the development host. Preserve existing home paths.

- **CLAUDE.md**: Update when adding/removing tools, changing build processes, or modifying architecture. Keep the tool locations table current.
- **README.md**: Update when adding/removing toolchains, changing usage instructions, or modifying VS Code extensions.
