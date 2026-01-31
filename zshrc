HISTSIZE=999999999
SAVEHIST=$HISTSIZE
setopt INC_APPEND_HISTORY   # save immediately
setopt SHARE_HISTORY        # share between sessions
setopt HIST_IGNORE_ALL_DUPS # ignore dups
setopt HIST_IGNORE_SPACE    # ignore entries starting with a line

setopt auto_cd
unsetopt beep

zstyle :compinstall filename "$HOME/.zshrc"
autoload -Uz compinit
compinit

autoload -U add-zsh-hook

##############
# key bindings

bindkey -e

bindkey '^H' backward-kill-word
bindkey '3~' kill-word
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

##############
# prompt

autoload -Uz vcs_info

precmd() {
  if [ -z "$_first_prompt" ]; then
    export _first_prompt="yes"
  else
    echo ""
  fi
  vcs_info
}
zstyle ':vcs_info:git:*' formats '%b '

setopt PROMPT_SUBST
PROMPT='%F{green}%D %*%f %F{blue}%~%f %F{red}${vcs_info_msg_0_}%f%F{8}${VIRTUAL_ENV_PROMPT}%f
$ '

# Paths
export PATH="/opt/claude-code/bin:/opt/bun/bin:/opt/dotnet:/opt/fzf/bin:/opt/uv:/opt/rust/cargo/bin:$PATH"

# Add ~/.local/bin to PATH if it exists
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"


# .NET
export DOTNET_ROOT="/opt/dotnet"
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# nvm
export NVM_DIR="/opt/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# fzf
source <(fzf --zsh)

# Aliases

alias ll='ls -alh --color=auto'
alias l='ls -lh --color=auto'
alias py='python3'
alias c='claude'