#!/usr/bin/env bash

set -eou pipefail

if [[ $(command -v brew) == "" ]]; then
    echo "Installing Hombrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Updating Homebrew"
    brew update
fi

brew install git
brew install gh
brew install jq
brew install wget
brew install coreutils
brew install bash
brew install bash-completion
brew install fzf
brew install gnupg
brew install ripgrep
brew install tree
brew install bat


