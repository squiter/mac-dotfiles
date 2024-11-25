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

# Configuring ASDF
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

if [[ "$(command -v node)" != *"asdf"* ]]; then
    echo "Installing nodejs..."
    asdf install nodejs 22.2.0
    asdf global nodejs 22.2.0
fi

if [[ "$(command -v yarn)" != *"asdf"* ]]; then
    echo "Installing yarn..."
    asdf install yarn 1.22.19
    asdf global yarn 1.22.19
fi

if [[ "$(command -v erl)" != *"asdf"* ]]; then
    echo "Installing erlang..."
    asdf install erlang 26.2.5
    asdf global erlang 26.2.5
fi

if [[ "$(command -v elixir)" != *"asdf"* ]]; then
    echo "Installing elixir..."
    asdf install elixir 1.17.3-otp-26
    asdf global elixir 1.17.3-otp-26
fi

## Emacs Congig
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

init_secrets_el_file="${code_dir}/emacs-dotfiles/dotfiles/.emacs.d/conf/init-secrets.el"
if [ ! -f "${init_secrets_el_file}" ]; then
    echo "Fetching init-secrets.el from Bitwarden..."
    copy_bw_notes_to init-secrets.el $init_secrets_el_file
else
    echo "init-secrets.el already configured..."
fi

## Setup Bash
if [ "${SHELL}" == "/opt/homebrew/bin/bash" ]; then
    echo "Homebrew bash is your default shell!"
else
    echo "Setting your default shell to (homebrew) bash..."
    if ! cat /etc/shells | grep -q "homebrew"; then
        echo "/usr/homebrew/bin/bash" | sudo tee -a /etc/shells
    fi
    sudo chsh -s /opt/homebrew/bin/bash "$USER"
    echo "Shell setted to (homebrew) bash successefully!"
fi

## Setup pre-commit hook to save Cursor extensions
if [ ! -f "${code_dir}/mac-dotfiles/.git/hooks/pre-commit" ]; then
    cp $code_dir/mac-dotfiles/pre-commit-base ${code_dir}/mac-dotfiles/.git/hooks/pre-commit
fi

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
