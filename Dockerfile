FROM debian:trixie-slim AS skytools-release

ARG SKYTOOLS_VERSION=v0.5.0
ARG TARGETARCH
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl \
  && rm -rf /var/lib/apt/lists/*
RUN set -eu; \
  architecture="${TARGETARCH:-$(dpkg --print-architecture)}"; \
  case "$architecture" in amd64|arm64) ;; *) echo "Unsupported architecture: $architecture" >&2; exit 1 ;; esac; \
  case "$SKYTOOLS_VERSION" in v[0-9]*) ;; *) echo 'SKYTOOLS_VERSION must be a release tag' >&2; exit 1 ;; esac; \
  asset="skytools_linux_${architecture}"; \
  release="https://github.com/sky87/skytools/releases/download/${SKYTOOLS_VERSION}"; \
  mkdir -p /tmp/skytools /out; \
  curl --fail --show-error --location --retry 3 "$release/$asset" -o "/tmp/skytools/$asset"; \
  curl --fail --show-error --location --retry 3 "$release/SHA256SUMS" -o /tmp/skytools/SHA256SUMS; \
  cd /tmp/skytools; \
  test "$(grep -c "  ${asset}$" SHA256SUMS)" = 1; \
  grep "  ${asset}$" SHA256SUMS | sha256sum --check -; \
  install -m 0755 "$asset" /out/skytools; \
  /out/skytools version; \
  rm -rf /tmp/skytools

FROM debian:trixie-slim AS devcontainer

ARG USERNAME=dev
ARG GROUPNAME=dev

ENV DEBIAN_FRONTEND=noninteractive

# Image utilities, compiler tools, and documents. Managed tools' prerequisites
# are resolved separately by skytools below.
RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  git \
  gnupg \
  neovim \
  sudo \
  tmux \
  zsh \
  jq \
  unzip \
  util-linux \
  xz-utils \
  build-essential \
  make \
  cmake \
  ninja-build \
  pkg-config \
  openssh-client \
  # C/C++ (clang)
  clang \
  clangd \
  clang-format \
  llvm \
  lld \
  lldb \
  libc++-dev \
  libc++abi-dev \
  libclang-rt-dev \
  uncrustify \
  # Python
  python3 \
  python3-venv \
  # Perf
  linux-perf \
  valgrind \
  # Coverage
  lcov \
  # LaTeX
  texlive-latex-recommended \
  texlive-fonts-recommended \
  texlive-latex-extra \
  latexmk \
  # Document tools
  pandoc \
  zip \
  imagemagick \
  && rm -rf /var/lib/apt/lists/*

# The same package list controls image prerequisites and persistent-home setup.
ARG SKYTOOLS_PACKAGES=all
ENV SKYTOOLS_PACKAGES=${SKYTOOLS_PACKAGES} \
  SKY_TOOLS_DISABLE_OPAM_SANDBOX=1
COPY --from=skytools-release /out/skytools /usr/local/bin/skytools
RUN ln -s skytools /usr/local/bin/sky-tools \
  && skytools deps install --only "$SKYTOOLS_PACKAGES" \
  && rm -rf /var/lib/apt/lists/*

# Create user with passwordless sudo and zsh shell
RUN useradd -m -s /bin/zsh ${USERNAME} \
  && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
  && chmod 0440 /etc/sudoers.d/${USERNAME}

# Mutable developer tools are installed after the persistent home volume is mounted.
ENV HOME=/home/${USERNAME}
ENV UV_INSTALL_DIR=${HOME}/.local/bin \
  RUSTUP_HOME=${HOME}/.rustup \
  CARGO_HOME=${HOME}/.cargo \
  NVM_DIR=${HOME}/.nvm \
  BUN_INSTALL=${HOME}/.bun \
  DOTNET_ROOT=${HOME}/.dotnet \
  GOROOT=${HOME}/.go/current \
  GOPATH=${HOME}/go \
  JAVA_HOME=${HOME}/.jdk/current \
  FZF_HOME=${HOME}/.fzf \
  OPAMROOT=${HOME}/.opam \
  ELAN_HOME=${HOME}/.elan \
  PNPM_HOME=${HOME}/.local/share/pnpm \
  DOTNET_CLI_TELEMETRY_OPTOUT=1 \
  LC_ALL=C.UTF-8 \
  LANG=C.UTF-8
ENV PATH="${HOME}/.local/bin:${HOME}/.opencode/bin:${PNPM_HOME}/bin:${PNPM_HOME}:${CARGO_HOME}/bin:${BUN_INSTALL}/bin:${DOTNET_ROOT}:${GOROOT}/bin:${GOPATH}/bin:${JAVA_HOME}/bin:${FZF_HOME}/bin:${OPAMROOT}/default/bin:${ELAN_HOME}/bin:${PATH}"

# Install the default shell configuration.
COPY zshrc /etc/zsh/zshrc

USER ${USERNAME}

# Fail the image build if the release cannot run or native prerequisites drift.
RUN skytools version && skytools deps --only "$SKYTOOLS_PACKAGES"
