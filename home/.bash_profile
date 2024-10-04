#!/usr/bin/env bash

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Ensure gpg-agent was running
eval "$(gpg-agent --daemon &>/dev/null)"

# Setting for the new UTF-8 terminal support in Lion
LC_CTYPE=en_US.UTF-8
LC_ALL=en_US.UTF-8


source_if_exists() {
    if [ -f "$1" ] ; then
        source "$1"
    fi
}

if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
    source_if_exists "$HOME/.ps1"
fi

source_if_exists "$HOME/.bash_secrets"
source_if_exists "$HOME/.bash_aliases"

# direnv config should be added after PROMPT_COMMAND (defined on .ps1)
source_if_exists "$HOME/osx_custom/dev"

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

export CDPATH=".:~/:~/Downloads:~/dev/code:~/dev/nu:~/dev/finbits"

# Ignore case
shopt -s cdspell
bind 'set completion-ignore-case on'

# Set my key as default
export GPGKEY=A86BDBC5

# FZF Configs
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind ctrl-k:kill-line,ctrl-g:abort"

# expansion of `source <(navi widget bash)` to rewrite the keybinding
__call_navi() {
    local -r result="$(navi --print)"
    local -r linecount="$(echo "$result" | wc -l)"

    if [[ "$linecount" -lt 2 ]]; then
        printf "$result"
        return 0
    fi

    IFS=$'\n'
    local i=1;
    for line in $result; do
        if echo "$line" | grep -q '\\$'; then
            printf "${line::-1} "
        elif [[ "$i" -eq "$linecount" ]]; then
            printf "$line "
        else
            printf "${line}; "
        fi
        i=$((i+1))
    done
}

bind '"\C-xn": " \C-b\C-k \C-u`__call_navi`\e\C-e\C-a\C-y\C-h\C-e\e \C-y\ey\C-x\C-x\C-f"'

# Bash Completion
[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"

# ASDF
source_if_exists $HOME/.asdf/asdf.sh
source_if_exists /opt/homebrew/opt/asdf/libexec/asdf.sh

# Automcompletion for ASDF
source_if_exists $HOME/.asdf/completions/asdf.bash
source_if_exists /opt/homebrew/opt/asdf/etc/bash_completion.d/asdf.bash

# Setup Java Home when installed by ASDF
source_if_exists $HOME/.asdf/plugins/java/set-java-home.bash

# FinBits custom Configurations
source_if_exists $HOME/.bash_finbits_customs

# OpenAI ChatGPT Functions
source_if_exists $HOME/.bash_functions_chatgpt

# Hishtory Config:
export PATH="$PATH:/Users/squiter/.hishtory"
source_if_exists /Users/squiter/.hishtory/config.sh

# Created by `pipx` on 2024-07-19 14:23:00
export PATH="$PATH:/Users/squiter/.local/bin"
