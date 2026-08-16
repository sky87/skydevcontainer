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
export PNPM_HOME="$HOME/.local/share/pnpm"
export OPAMROOT="$HOME/.opam"
export ELAN_HOME="$HOME/.elan"
export PATH="$HOME/.local/bin:$PNPM_HOME/bin:$PNPM_HOME:$HOME/.cargo/bin:$HOME/.bun/bin:$HOME/.dotnet:$HOME/.fzf/bin:$OPAMROOT/default/bin:$ELAN_HOME/bin:$PATH"

# opam
[ -s "$OPAMROOT/opam-init/init.zsh" ] && . "$OPAMROOT/opam-init/init.zsh" > /dev/null 2> /dev/null


# .NET
export DOTNET_ROOT="$HOME/.dotnet"
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# fzf
command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)

# Aliases

alias ll='ls -alh --color=auto'
alias l='ls -lh --color=auto'
alias py='python3'
alias c='claude'
