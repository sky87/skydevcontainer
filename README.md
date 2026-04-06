# Sky Dev Container

A VS Code Dev Container with a multi-language development environment based on Debian Trixie.

## Included Toolchains

- **C/C++**: Clang, clangd, clang-format, lld, lldb, libc++
- **Rust**: rustup with cargo
- **Python**: Python 3 with uv package manager
- **Node.js**: via nvm (LTS version)
- **Bun**: JavaScript/TypeScript runtime and package manager
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

### Use in a New Project

Copy the `example/.devcontainer` directory to the root of your project:

```bash
cp -r example/.devcontainer /path/to/your/project/
```

Then open the project in VS Code with the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension and click "Reopen in Container" when prompted.

## Configuration

- **User**: `sky` with passwordless sudo
- **Shell**: zsh
- **Home directory**: Persisted via Docker volume (`sky-home`)
- **Image**: Published to `ghcr.io/sky87/skydevcontainer:latest`

## Automatic Dependency Installation

The included `post-create.sh` automatically installs dependencies when the container starts:

- **Node.js**: Runs `bun install` if `package.json` exists
- **Python**: Runs `uv sync` or `uv pip install -r requirements.txt`
- **Rust**: Runs `cargo fetch` if `Cargo.toml` exists
- **.NET**: Runs `dotnet restore` for C#/F# projects

## VS Code Extensions

The following extensions are automatically installed:

- rust-analyzer
- Python + Ruff
- clangd
- LaTeX Workshop
- C# Dev Kit
- Bun
