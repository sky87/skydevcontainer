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
- Utilities: git, GitHub CLI (`gh`), curl, fzf, btop, Neovim, tmux, zsh, openssh-client
- Documents: pandoc, imagemagick, zip
- Profiling/coverage: linux-perf, valgrind, lcov
- AI: Claude Code CLI, Codex CLI, OpenCode, pi
- Browser automation: Microsoft's `playwright-cli` for agents, Playwright Node
  libraries with `playwright-node` for scripts, Chromium, Firefox, and WebKit

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
skytools ensure --only "${SKYTOOLS_PACKAGES:-all}"
```

Update every managed tool explicitly or inspect the installed versions:

```bash
skytools                         # interactive installed/latest versions and updates
skytools update --only "${SKYTOOLS_PACKAGES:-all}" # update selected tools explicitly
skytools status                  # fast, offline local inventory
skytools status --versions       # query installed executables
skytools deps --only "${SKYTOOLS_PACKAGES:-all}" # inspect selected system prerequisites
skytools deps install --only playwright-cli # explicitly install missing prerequisites as root
```

`skytools` manages uv, Rust, nvm/Node.js, pnpm, Bun, .NET, Go, the Amazon
Corretto JDK, fzf, GitHub CLI, opam/OCaml, elan/Lean 4, Claude Code, Codex,
OpenCode, pi, btop, Playwright, and the Playwright agent CLI. Operating-system
packages and native libraries remain part of the container image. The existing
apt list supplies unrelated image tools such as Clang, editors, and document
utilities; `skytools deps install` supplies the selected managed tools' system
prerequisites. Required packages are checked again before installations and
updates; a missing prerequisite stops the operation with a command to run.
Downloaded Go, Corretto, GitHub CLI, and btop archives are
verified against the checksums published with their releases.
Node.js, .NET, Java, and OCaml resolve the latest upstream LTS; other tools use
their latest stable channels. The old runtime-version overrides are not used.
`sky-tools` remains a compatibility alias for the same executable.

The executable is root-owned at `/usr/local/bin/skytools`, with
`/usr/local/bin/sky-tools` as a compatibility symlink. Managed tools go into the
persistent `/home/dev` instead.

The image defaults to skytools `v0.5.0`. Select another published manager release
with `docker build --build-arg SKYTOOLS_VERSION=vX.Y.Z -t devcontainer-dev:latest .`.
Both Linux amd64 and arm64 download their matching binary and verify SHA-256.
The image build runs `skytools deps install --only "$SKYTOOLS_PACKAGES"` as root,
then verifies the selected prerequisites as the target user.

`SKYTOOLS_PACKAGES` is a comma-separated build argument, defaulting to `all`.
It is also saved in the image environment for `post-create.sh`. For example:

```bash
docker build --build-arg SKYTOOLS_PACKAGES=go,uv,playwright-cli -t devcontainer-dev:latest .
```

The example selects Go, uv, and the agent CLI, plus its Playwright and Node
dependencies. Tool dependencies are declared in skytools code and resolved for
both system prerequisites and home installation. Changing the list requires an
image rebuild to include its prerequisites. Existing tools in the persistent home
are retained. Project restore steps skip tools that are unavailable.

For browser scripts, use `playwright-node script.mjs` or `playwright-node script.cjs`
to import `playwright`/`playwright-core` from the shared home installation.
Project-local packages take precedence. The agent CLI defaults to downloaded
Chromium; existing user or project configuration is preserved.

`skytools self-update` updates a user-owned executable from GitHub's latest stable
release. The image-owned `/usr/local/bin/skytools` requires rebuilding the image;
for independent home updates, copy it into `~/.local/bin/skytools` first and run
that copy's `self-update` command.

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
