#!/usr/bin/env bash

set -eou pipefail

mkdir -p ~/dev/code ~/dev/finbits

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

brew tap homebrew/cask-fonts

install_if_needed git
install_if_needed gh
install_if_needed jq
install_if_needed wget
install_if_needed gcat coreutils
install_if_needed bash
install_if_needed bash_completion bash-completion
install_if_needed fzf
install_if_needed gnupg
install_if_needed rg ripgrep
install_if_needed tree
install_if_needed bat
install_if_needed tldr

install_cask_if_needed slack
install_cask_if_needed raycast
install_cask_if_needed iterm2
install_cask_if_needed font-fira-code
install_cask_if_needed font-iosevka
install_cask_if_needed font-hack-nerd-font
install_cask_if_needed spotify
install_cask_if_needed todoist
install_cask_if_needed zoom
install_cask_if_needed obs
install_cask_if_needed appcleaner
