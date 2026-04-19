FROM debian:trixie-slim

ARG USERNAME=dev
ARG GROUPNAME=dev

ENV DEBIAN_FRONTEND=noninteractive

# Base utilities + toolchains
RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  git \
  gnupg \
  sudo \
  zsh \
  jq \
  unzip \
  build-essential \
  make \
  cmake \
  ninja-build \
  bubblewrap \
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
  # .NET dependencies
  libicu-dev \
  libssl-dev \
  # Playwright firefox dependencies
  libasound2 \
  libatk1.0-0t64 libcairo-gobject2 libcairo2 libdbus-1-3 libdbus-glib-1-2 \
  libfontconfig1 libfreetype6 libgdk-pixbuf-2.0-0 libglib2.0-0t64 libgtk-3-0t64 \
  libharfbuzz0b libpango-1.0-0 libpangocairo-1.0-0 libx11-6 libx11-xcb1 libxcb-shm0 \
  libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 \
  libxrandr2 libxrender1 libxtst6 xvfb fonts-liberation fonts-freefont-ttf \
  && rm -rf /var/lib/apt/lists/*

# Create user with passwordless sudo and zsh shell
RUN useradd -m -s /bin/zsh ${USERNAME} \
  && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
  && chmod 0440 /etc/sudoers.d/${USERNAME}

# Install uv to /opt/uv (user-owned for self-update)
ENV UV_INSTALL_DIR=/opt/uv
RUN curl --retry 5 --retry-all-errors --retry-delay 2 -LsSf https://astral.sh/uv/install.sh | sh \
  && chown -R ${USERNAME}:${GROUPNAME} ${UV_INSTALL_DIR}

# Install Rust to /opt/rust (user-owned for rustup update)
ENV RUSTUP_HOME=/opt/rust/rustup \
  CARGO_HOME=/opt/rust/cargo
RUN curl --retry 5 --retry-all-errors --retry-delay 2 --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path \
  && chown -R ${USERNAME}:${GROUPNAME} /opt/rust

# Install nvm to /opt/nvm (user-owned for nvm install/upgrade)
ENV NVM_DIR=/opt/nvm
RUN mkdir -p ${NVM_DIR} \
  && curl --retry 5 --retry-all-errors --retry-delay 2 -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash \
  && chown -R ${USERNAME}:${GROUPNAME} ${NVM_DIR}

# Install fzf from source (latest)
ENV FZF_HOME=/opt/fzf
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ${FZF_HOME} \
  && ${FZF_HOME}/install --bin \
  && chown -R ${USERNAME}:${GROUPNAME} ${FZF_HOME}

# Install .NET to /opt/dotnet (user-owned for updates)
ENV DOTNET_ROOT=/opt/dotnet \
  DOTNET_CLI_TELEMETRY_OPTOUT=1
RUN mkdir -p ${DOTNET_ROOT} \
  && curl --retry 5 --retry-all-errors --retry-delay 2 -fsSL https://dot.net/v1/dotnet-install.sh | bash -s -- --install-dir ${DOTNET_ROOT} --channel LTS \
  && chown -R ${USERNAME}:${GROUPNAME} ${DOTNET_ROOT}

# Install Claude Code to /opt/claude-code (user-owned for updates)
ENV CLAUDE_CODE_HOME=/opt/claude-code
RUN curl --retry 5 --retry-all-errors --retry-delay 2 -fsSL https://claude.ai/install.sh | bash \
  && mkdir -p ${CLAUDE_CODE_HOME}/bin \
  && mv /root/.local/share/claude ${CLAUDE_CODE_HOME}/data \
  && ln -s "$(ls ${CLAUDE_CODE_HOME}/data/versions/* | head -1)" ${CLAUDE_CODE_HOME}/bin/claude \
  && rm -rf /root/.claude /root/.local \
  && chown -R ${USERNAME}:${GROUPNAME} ${CLAUDE_CODE_HOME}

# Install Bun to /opt/bun (user-owned for updates)
ENV BUN_INSTALL=/opt/bun
RUN curl --retry 5 --retry-all-errors --retry-delay 2 -fsSL https://bun.sh/install | bash \
  && chown -R ${USERNAME}:${GROUPNAME} ${BUN_INSTALL}

# Create pnpm global dir (user-owned for updates)
ENV PNPM_HOME=/opt/pnpm
RUN mkdir -p ${PNPM_HOME} && chown -R ${USERNAME}:${GROUPNAME} ${PNPM_HOME}

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV PATH="${PNPM_HOME}:${CARGO_HOME}/bin:$PATH"

# Copy default zshrc to system location
COPY zshrc /etc/zsh/zshrc

USER ${USERNAME}

# Install Node.js + pnpm + global packages as user (so user can upgrade them)
RUN bash -c "source ${NVM_DIR}/nvm.sh && nvm install --lts"
RUN bash -c "source ${NVM_DIR}/nvm.sh && npm i -g pnpm"
RUN bash -c "source ${NVM_DIR}/nvm.sh && pnpm add -g @openai/codex"
RUN bash -c "source ${NVM_DIR}/nvm.sh && pnpm add -g @mariozechner/pi-coding-agent"
