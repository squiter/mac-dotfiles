#!/usr/bin/env bash

set -eou pipefail

code_dir="${HOME}/dev/code"
remote_dir="${HOME}/dev/remote"
bin_dir="${HOME}/bin"

if [[ -d $code_dir || -d $remote_dir ]]; then
    echo "Project directories already created"
else
    mkdir -p $code_dir $remote_dir
fi

# To avoid having a ~/bin as an alias
if [[ -d $bin_dir ]]; then
    echo "~/bin directory already created"
else
    mkdir $bin_dir
fi

if [[ $(command -v brew) == "" ]]; then
    echo "Installing Hombrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Updating Homebrew"
    brew update
fi

# Installing all dependencies from Brewfile
brew bundle

# Yabai & skhd services
yabai --start-service
skhd --start-service

# Git-lfs installation
git lfs install

# Configuring Mise
if [[ "$(command -v node)" != *"mise"* ]]; then
    echo "Installing nodejs..."
    mise install nodejs@22.2.0
    mise use --global nodejs@22.2.0
fi

if [[ "$(command -v yarn)" != *"mise"* ]]; then
    echo "Installing yarn..."
    mise install yarn@1.22.19
    mise use --global yarn@1.22.19
fi

if [[ "$(command -v erl)" != *"mise"* ]]; then
    echo "Installing erlang..."
    mise install erlang@27.2
    mise use --glocal erlang@27.2
fi

if [[ "$(command -v elixir)" != *"mise"* ]]; then
    echo "Installing elixir..."
    mise install elixir@1.18.1
    mise use --global elixir@1.18.1
fi

## Emacs Congig
ln -fs /opt/homebrew/opt/emacs-plus@30/Emacs.app /Applications

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

echo "Synchronizing Bitwarden Vault"
bw sync

# Defining a function to get BW notes in a safe way
copy_bw_notes_to () {
    local secret=$1
    local target=$2

    echo "==> Getting ${secret} from Bitwarden and saving at ${target}..."
    bw get notes $secret > /tmp/$secret

    if [ -s /tmp/$secret ]; then
        echo "Coping content to ${target}..."
        cat /tmp/$secret > $target
        rm /tmp/$secret
    else
        echo "/tmp/${secret} is empty!"
        return 1
    fi
}

## Setup Fish
if [ "${SHELL}" == "/opt/homebrew/bin/fish" ]; then
    echo "Homebrew fish 🐠 is your default shell!"
else
    echo "Setting your default shell to (homebrew) fish..."
    if ! cat /etc/shells | grep -q "homebrew"; then
        echo "/usr/homebrew/bin/fish" | sudo tee -a /etc/shells
    fi
    sudo chsh -s /opt/homebrew/bin/fish "$USER"
    echo "Shell setted to (homebrew) fish successefully!"
fi

colima_fish_completion="${HOME}/.config/fish/completions/colima.fish"
if [ ! -f "${colima_fish_completion}" ]; then
    echo "Setting up 🐠 completion for Colima..."
    colima completion fish > $colima_fish_completion
fi

## Setup pre-commit hook to save Cursor extensions
if [ ! -f "${code_dir}/mac-dotfiles/.git/hooks/pre-commit" ]; then
    cp $code_dir/mac-dotfiles/pre-commit-base ${code_dir}/mac-dotfiles/.git/hooks/pre-commit
fi

. $code_dir/mac-dotfiles/home/bin/sync_cursor_extensions

## Create the symlinks of my dotfiles (without linking directories)
cd $code_dir/mac-dotfiles
stow --verbose --no-folding --target=$HOME home

authinfo_file="${HOME}/.authinfo"
if [ ! -f "${authinfo_file}" ]; then
    echo "Fetching authfinfo from Bitwarden..."
    copy_bw_notes_to authinfo $authinfo_file
else
    echo "authfinfo already configured..."
fi

if [ ! -f ~/.config/iterm2/shades-of-purple.itermcolors ]; then
    echo "Fetching shades-of-purple.itermcolors from Github..."
    curl https://raw.githubusercontent.com/ahmadawais/shades-of-purple-iterm2/master/shades-of-purple.itermcolors > ~/.config/iterm2/shades-of-purple.itermcolors
else
    echo "shades-of-purple.itermcolors already configured..."
fi

echo "You could need some apps from https://sindresorhus.com/apps that was not available at Homebrew"
echo "Setup completed!"
