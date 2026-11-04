# Dev Container

A VS Code Dev Container with a multi-language development environment based on Debian Trixie.

## Included Toolchains

- **C/C++**: Clang, clangd, clang-format, lld, lldb, libc++, uncrustify
- **Rust**: rustup with cargo
- **Python**: Python 3 with uv package manager
- **Node.js**: via nvm (LTS version) with pnpm
- **Bun**: JavaScript/TypeScript runtime and package manager
- **.NET**: LTS version
- **Go**: latest stable release
- **Java**: latest Java LTS via Amazon Corretto
- **OCaml**: latest upstream LTS compiler via opam
- **Lean 4**: stable release channel via elan
- **LaTeX**: texlive with latexmk

## Additional Tools

- Build tools: make, cmake, ninja-build
- Utilities: git, GitHub CLI (`gh`), curl, fzf, btop, Neovim, tmux, zsh, openssh-client, bubblewrap
- Documents: pandoc, imagemagick, zip
- Profiling/coverage: linux-perf, valgrind, lcov
- AI: Claude Code CLI, Codex CLI, OpenCode, pi

## Persistent Developer Tools

Frequently updated runtimes and CLI tools are installed into the `dev` user's
home directory by [skytools](https://github.com/sky87/skytools), downloaded as a
checksummed executable from its public GitHub releases when the image is built.
The example configuration mounts that home as a
named Docker volume, so updates survive container recreation and are shared by
projects using the same volume.

The first container creation installs any missing tools. Existing tools are not
updated automatically:

```bash
skytools ensure
```

Update every managed tool explicitly or inspect the installed versions:

```bash
skytools                         # interactive installed/latest versions and updates
skytools update                  # update explicitly to current LTS/stable releases
skytools status                  # fast, offline local inventory
skytools status --versions       # query installed executables
skytools deps                    # inspect required system packages
```

`skytools` manages uv, Rust, nvm/Node.js, pnpm, Bun, .NET, Go, the Amazon
Corretto JDK, fzf, GitHub CLI, opam/OCaml, elan/Lean 4, Claude Code, Codex,
OpenCode, pi, and btop. Operating-system packages and native libraries remain part
of the container image. Required packages are checked before installations and
updates; a missing prerequisite stops the operation with an apt command to run.
Downloaded Go, Corretto, GitHub CLI, and btop archives are
verified against the checksums published with their releases.
Node.js, .NET, Java, and OCaml resolve the latest upstream LTS; other tools use
their latest stable channels. The old runtime-version overrides are not used.
`sky-tools` remains a compatibility alias for the same executable.

The image defaults to skytools `v0.3.0`. Select another published manager release
with `docker build --build-arg SKYTOOLS_VERSION=vX.Y.Z -t devcontainer-dev:latest .`.
Both Linux amd64 and arm64 download their matching binary and verify SHA-256.
The image build runs `skytools deps` to verify the complete native package set.

Opam package sandboxing is explicitly disabled with
`SKY_TOOLS_DISABLE_OPAM_SANDBOX=1` because unprivileged user namespaces are
unavailable inside the container; Docker provides the outer isolation
boundary.

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

- **User**: `dev` with passwordless sudo (configurable via `USERNAME` build arg)
- **Shell**: zsh
- **Home directory**: Persisted via Docker volume (`dev-home`)
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
- Claude Code
