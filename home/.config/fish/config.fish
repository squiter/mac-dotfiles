if status is-interactive
    function fish_prompt
        set -l last_status $status
        if test $last_status -ne 0
            set stat (set_color red)"💩"(set_color normal)
        else
            set stat "🐠"
        end

        string join '' -- $stat ' ' (set_color green) '[📁 ' (prompt_pwd)']' (set_color normal) (fish_git_prompt) '> '
    end

    # Homebrew
    eval "$(/opt/homebrew/bin/brew shellenv)"

    # https://docs.brew.sh/Shell-Completion
    if test -d (brew --prefix)"/share/fish/completions"
        set -p fish_complete_path (brew --prefix)/share/fish/completions
    end

    if test -d (brew --prefix)"/share/fish/vendor_completions.d"
        set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
    end

    # Ensure gpg-agent was running
    eval "$(gpg-agent --daemon &>/dev/null)"

    # Set my key as default
    set -x GPGKEY A86BDBC5

    # Mise
    eval "$(/opt/homebrew/bin/mise activate fish)"

    function source_if_exists
        if test -f $argv[1]
            source $argv[1]
        end
    end

    source_if_exists $HOME/.secrets.fish

    # set PATH so it inclucdes user's bin
    if test -d $HOME/bin
        fish_add_path -aP $HOME/bin
    end

    # Used for ElixirLS
    fish_add_path -aP $HOME/.local/bin

    # FZF Configs
    set -x FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border'
    set -x FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS --bind ctrl-k:kill-line,ctrl-g:abort"

    # Some aliases gotten from ~/.bash_aliases
    abbr -a ls 'lsd'
    abbr -a lslast 'ls -lt | head'

    # Must be an alias because it's used on a keybind
    alias all_projects="find ~/dev -maxdepth 2 -type d -mindepth 2"

    # Direnv
    direnv hook fish | source

    # Elixir
    function ecto_rebuild_db
        set env $argv[1]
        test -z "$env"; and set env "dev"
        echo  "==> Rebuilding database for $env environment..."
        MIX_ENV=$env mix ecto.drop
        MIX_ENV=$env mix ecto.create
        MIX_ENV=$env mix ecto.migrate
    end

    if not string match --quiet --regex -- "Hyrule" $hostname
       source_if_exists $HOME/.config/fish/remote.config.fish
    end

    # Remote aliases

    # Keybinds
    function fish_user_key_bindings
        bind \cxo 'cd $(all_projects | fzf); commandline -f repaint'
    end
end
