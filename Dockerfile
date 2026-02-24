FROM debian:trixie-slim@sha256:77ba0164de17b88dd0bf6cdc8f65569e6e5fa6cd256562998b62553134a00ef0

ENV DEBIAN_FRONTEND=noninteractive

# Base utilities + toolchains
RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  git \
  gnupg \
  sudo \
  zsh \
  unzip \
  build-essential \
  make \
  cmake \
  ninja-build \
  pkg-config \
  # C/C++ (clang)
  clang \
  clangd \
  clang-format \
  lld \
  lldb \
  libc++-dev \
  libc++abi-dev \
  libclang-rt-dev \
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
RUN useradd -m -s /bin/zsh sky \
  && echo "sky ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sky \
  && chmod 0440 /etc/sudoers.d/sky

# Install uv to /opt/uv (sky-owned for self-update)
ENV UV_INSTALL_DIR=/opt/uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
  && chown -R sky:sky /opt/uv

# Install Rust to /opt/rust (sky-owned for rustup update)
ENV RUSTUP_HOME=/opt/rust/rustup \
  CARGO_HOME=/opt/rust/cargo
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path \
  && chown -R sky:sky /opt/rust

# Install nvm to /opt/nvm (sky-owned for nvm install/upgrade)
ENV NVM_DIR=/opt/nvm
RUN mkdir -p /opt/nvm \
  && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash \
  && chown -R sky:sky /opt/nvm

# Install default Node.js via nvm
RUN bash -c "source /opt/nvm/nvm.sh && nvm install --lts"

# Install fzf from source (latest)
RUN git clone --depth 1 https://github.com/junegunn/fzf.git /opt/fzf \
  && /opt/fzf/install --bin \
  && chown -R sky:sky /opt/fzf

# Install .NET to /opt/dotnet (sky-owned for updates)
ENV DOTNET_ROOT=/opt/dotnet \
  DOTNET_CLI_TELEMETRY_OPTOUT=1
RUN mkdir -p /opt/dotnet \
  && curl -fsSL https://dot.net/v1/dotnet-install.sh | bash -s -- --install-dir /opt/dotnet --channel LTS \
  && chown -R sky:sky /opt/dotnet

# Install Claude Code to /opt/claude-code (sky-owned for updates)
RUN curl -fsSL https://claude.ai/install.sh | bash \
  && mkdir -p /opt/claude-code/bin \
  && mv /root/.local/share/claude /opt/claude-code/data \
  && ln -s "$(ls /opt/claude-code/data/versions/* | head -1)" /opt/claude-code/bin/claude \
  && rm -rf /root/.claude /root/.local \
  && chown -R sky:sky /opt/claude-code

# Install Bun to /opt/bun (sky-owned for updates)
ENV BUN_INSTALL=/opt/bun
RUN curl -fsSL https://bun.sh/install | bash \
  && chown -R sky:sky /opt/bun

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV PATH="/opt/rust/cargo/bin:$PATH"

# Copy default zshrc to system location
COPY zshrc /etc/zsh/zshrc

USER sky
WORKDIR /home/sky

RUN cargo install \
  flamegraph \
  rustfilt