# Sky Dev Container

A VS Code Dev Container with a multi-language development environment based on Debian Trixie.

## Included Toolchains

- **C/C++**: Clang, clangd, clang-format, lld, lldb, libc++
- **Rust**: rustup with cargo
- **Python**: Python 3 with uv package manager
- **Node.js**: via nvm (LTS version)
- **.NET**: LTS version
- **LaTeX**: texlive with latexmk

## Additional Tools

- Build tools: make, cmake, ninja-build
- Utilities: git, curl, fzf, zsh
- AI: Claude Code CLI

## Usage

### Build the Image

```bash
./build.sh
```

### Open in VS Code

1. Install the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension
2. Open this folder in VS Code
3. Click "Reopen in Container" when prompted

## Configuration

- **User**: `sky` with passwordless sudo
- **Shell**: zsh
- **Home directory**: Persisted via Docker volume (`sky-home`)

## VS Code Extensions

The following extensions are automatically installed:

- rust-analyzer
- Python + Ruff
- clangd
- LaTeX Workshop
- C# Dev Kit
