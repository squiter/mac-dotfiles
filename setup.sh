#!/usr/bin/env bash

set -eou pipefail

code_dir="${HOME}/dev/code"
finbits_dir="${HOME}/dev/finbits"

if [[ -d $code_dir || -d $finbits_dir ]]; then
    echo "Project directories already created"
else
    mkdir -p $code_dir $finbits_dir
fi

if [[ $(command -v brew) == "" ]]; then
    echo "Installing Hombrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Updating Homebrew"
    brew update
fi

install_if_needed() {
    local binary=$1
    local package=${2:-$1}
    if [[ -e "/opt/homebrew/bin/${binary}" || -L "/opt/homebrew/bin/${binary}" || -e "/opt/homebrew/etc/${binary}" || -L "/opt/homebrew/etc/${binary}" ]]; then
        echo "${1} already installed..."
    else
        brew install $package
    fi
}

install_cask_if_needed() {
    local package=${1}
    if [[ -e "/opt/homebrew/Caskroom/${package}" ]]; then
        echo "${1} already installed..."
    else
        brew install --cask $package
    fi
}

install_if_needed asdf
install_if_needed awscli
install_if_needed bash
install_if_needed bash_completion bash-completion
install_if_needed bat
install_if_needed bw bitwarden-cli
install_if_needed direnv
install_if_needed borkdude/brew/babashka
install_if_needed fzf
install_if_needed gcat coreutils
install_if_needed gh
install_if_needed git
install_if_needed gnupg
install_if_needed jq
install_if_needed lsd
install_if_needed pinentry-mac
install_if_needed rg ripgrep
install_if_needed rga pandoc poppler ffmpeg
install_if_needed stow
install_if_needed the_silver_searcher
install_if_needed terraform
install_if_needed tldr
install_if_needed tree
install_if_needed wget
install_if_needed wxwidgets

. $HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh

asdf_folder="$HOME/.asdf"

if [ ! -d "$asdf_folder/plugins/nodejs" ]; then
    asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
fi

if [ ! -d "$asdf_folder/plugins/yarn" ]; then
    asdf plugin add yarn
fi

if [ ! -d "$asdf_folder/plugins/erlang" ]; then
    asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
fi

if [ ! -d "$asdf_folder/plugins/elixir" ]; then
   asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
fi

asdf plugin update --all

if ! [ -x "$(command -v node)" ]; then
    echo "Installing nodejs..."
    asdf install nodejs 22.2.0
    asdf global nodejs 22.2.0
fi

if ! [ -x "$(command -v yarn)" ]; then
    echo "Installing yarn..."
    asdf install yarn 1.22.19
    asdf global yarn 1.22.19
fi

if ! [ -x "$(command -v erl)" ]; then
    echo "Installing erlang..."
    asdf install erlang 26.2.5
    asdf global erlang 26.2.5
fi

if ! [ -x "$(command -v elixir)" ]; then
    echo "Installing elixir..."
    asdf install elixir 1.17.3-otp-26
    asdf global elixir 1.17.3-otp-26
fi

install_if_needed pipx

install_cask_if_needed appcleaner
install_cask_if_needed arc
install_cask_if_needed bitwarden
install_cask_if_needed docker
install_cask_if_needed dropbox
install_cask_if_needed font-fira-code
install_cask_if_needed font-hack-nerd-font
install_cask_if_needed font-iosevka
install_cask_if_needed height
install_cask_if_needed iterm2
install_cask_if_needed jordanbaird-ice
install_cask_if_needed latest
install_cask_if_needed obs
install_cask_if_needed raycast
install_cask_if_needed rescuetime
install_cask_if_needed roam-research
install_cask_if_needed rocket
install_cask_if_needed shottr
install_cask_if_needed slack
install_cask_if_needed spotify
install_cask_if_needed todoist
install_cask_if_needed zoom
install_cask_if_needed easydict


## Emacs
brew tap d12frosted/emacs-plus
install_if_needed emacs-plus@29

install_if_needed ispell
install_if_needed aspell
install_if_needed wakatime wakatime-cli

ln -fs /opt/homebrew/opt/emacs-plus@29/Emacs.app /Applications


if [[ -e /Applications/Emacs.app ]]; then
    echo "Emacs.app already at /Applications"
else
    ln -fs /opt/homebrew/opt/emacs-plus@29/Emacs.app /Applications
fi

if [ ! -d "${code_dir}/emacs-dotfiles" ]; then
    git clone git@github.com:squiter/emacs-dotfiles.git $code_dir/emacs-dotfiles
else
    echo "Emacs already configured..."
fi

cd $code_dir/emacs-dotfiles
stow --verbose --target=$HOME dotfiles
cd -

## Setup Bash
# TODO: This check isn't working...
if [ "${0}" == "-bash" ]; then
    echo "Homebrew bash is your default shell!"
else
    echo "Setting your default shell to (homebrew) bash..."
    if ! cat /etc/shells | grep -q "homebrew"; then
        echo "/usr/homebrew/bin/bash" | sudo tee -a /etc/shells
    fi
    sudo chsh -s /opt/homebrew/bin/bash "$USER"
    echo "Shell setted to (homebrew) bash successefully!"
fi

## Create the symlinks of my dotfiles
cd $code_dir/mac-dotfiles
stow --verbose --target=$HOME home

echo "Setup completed!"
