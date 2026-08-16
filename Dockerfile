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
  # Playwright browser dependencies
  libasound2 \
  libatk1.0-0t64 libcairo-gobject2 libcairo2 libdbus-1-3 libdbus-glib-1-2 \
  libfontconfig1 libfreetype6 libgdk-pixbuf-2.0-0 libglib2.0-0t64 libgtk-3-0t64 \
  libharfbuzz0b libpango-1.0-0 libpangocairo-1.0-0 libx11-6 libx11-xcb1 libxcb-shm0 \
  libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 \
  libxrandr2 libxrender1 libxtst6 libnspr4 libnss3 \
  fonts-noto-color-emoji fonts-ipafont-gothic fonts-tlwg-loma-otf \
  fonts-unifont fonts-wqy-zenhei fonts-liberation fonts-freefont-ttf \
  xvfb xfonts-encodings xfonts-scalable xfonts-utils xserver-common \
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
  FZF_HOME=${HOME}/.fzf \
  PNPM_HOME=${HOME}/.local/share/pnpm \
  DOTNET_CLI_TELEMETRY_OPTOUT=1 \
  LC_ALL=C.UTF-8 \
  LANG=C.UTF-8
ENV PATH="${HOME}/.local/bin:${PNPM_HOME}/bin:${PNPM_HOME}:${CARGO_HOME}/bin:${BUN_INSTALL}/bin:${DOTNET_ROOT}:${FZF_HOME}/bin:${PATH}"

# Install the persistent tool manager and default shell configuration.
COPY --chmod=0755 sky-tools /usr/local/bin/sky-tools
COPY zshrc /etc/zsh/zshrc

USER ${USERNAME}
