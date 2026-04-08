# ~/.zshenv

# XDG directories
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$UID}"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

export PATH="$HOME/.local/bin:$PATH"
export WINEPREFIX="$XDG_DATA_HOME/wineprefixes/default"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export GOPATH="$XDG_DATA_HOME/go"
export GOMODCACHE="$XDG_CACHE_HOME/go/mod"
export SQLITE_HISTORY="$XDG_DATA_HOME/sqlite_history"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export TMUX_TMPDIR="$XDG_RUNTIME_DIR"

export HISTFILE="$XDG_DATA_HOME/history"
HISTSIZE=1000
SAVEHIST=1000

# Source main interactive config
[ -f "$XDG_CONFIG_HOME/zsh/zshrc" ] && source "$XDG_CONFIG_HOME/zsh/zshrc"
