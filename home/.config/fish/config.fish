if status is-interactive
    function fish_prompt
        set -l last_status $status
        if test $last_status -ne 0
            set stat (set_color red)"[💩]"(set_color normal)
        end

        string join '' -- $stat 🐠 ' ' (set_color green) (prompt_pwd) (set_color normal) (fish_git_prompt) '> '
    end

    # Homebrew
    eval "$(/opt/homebrew/bin/brew shellenv)"

    # Ensure gpg-agent was running
    eval "$(gpg-agent --daemon &>/dev/null)"

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

    # Set my key as default
    set -x GPGKEY A86BDBC5

    # FZF Configs
    set -x FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border'
    set -x FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS --bind ctrl-k:kill-line,ctrl-g:abort"

    # Some aliases gotten from ~/.bash_aliases
    alias ls='lsd'
    alias lslast='ls -lt | head'
    alias all_projects="find ~/dev -maxdepth 2 -type d -mindepth 2"

    # Elixir
    function ecto_rebuild_db
        set env $argv[1]
        test -z "$env"; and set env "dev"
        echo  "==> Rebuilding database for $env environment..."
        MIX_ENV=$env mix ecto.drop
        MIX_ENV=$env mix ecto.create
        MIX_ENV=$env mix ecto.migrate
    end

    # Remote aliases
    alias neo-nld-tests="MIX_ENV=test mix do --app netherlands test"
    alias neo-nld-e2e="MIX_ENV=e2e mix test.e2e apps/neo_web/test/e2e/netherlands"
    alias neo-nld-api-tests="mix test apps/neo_web/test/unit/neo_web/controllers/api/v1/netherlands"
    alias neo-nld-all-tests="neo-nld-tests && neo-nld-e2e && neo-nld-api-tests"

    # Keybinds
    function fish_user_key_bindings
        bind \cxo 'cd $(all_projects | fzf); commandline -f repaint'
    end
end
