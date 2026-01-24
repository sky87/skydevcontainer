# === Devcontainer tools ===

# Paths
export PATH="/opt/claude-code:/opt/dotnet:/opt/fzf/bin:/opt/uv:/opt/rust/cargo/bin:$PATH"

# .NET
export DOTNET_ROOT="/opt/dotnet"
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# nvm
export NVM_DIR="/opt/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# fzf
[ -f /opt/fzf/shell/completion.zsh ] && source /opt/fzf/shell/completion.zsh
[ -f /opt/fzf/shell/key-bindings.zsh ] && source /opt/fzf/shell/key-bindings.zsh
