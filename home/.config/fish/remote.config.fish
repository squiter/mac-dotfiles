if status is-interactive
    # AWS Config
    set -xU AWS_DEFAULT_PROFILE 'sts'

    if not command -q remotectl
        echo "remotectl not found! Installing..."
        mise plugin add remotectl git@gitlab.com:remote-com/devops/asdf-remotectl.git
        mise use remotectl@latest --global
    end

    if not test -f $fish_complete_path[1]/remotectl.fish
        echo "remotectl autocomplete file not found! Generating..."
        remotectl completion fish > $fish_complete_path[1]/remotectl.fish
    end

    # Prepend "-m" the workbrew path before the default homebrew
    fish_add_path -m /opt/workbrew/bin

    # PSQL load path
    fish_add_path -aP $HOMEBREW_PREFIX/opt/libpq/bin

    if not string match -q "*homebrew*" (command -v icu-config)
        # Lib icu4c for postgrew 17
        brew link icu4c --force
    end

    # Loading the launchctl from binaries installed by Mise
    if not launchctl list | grep dev.remote.postgres &>/dev/null
        launchctl load ~/Library/LaunchAgents/dev.remote.postgres.mise.plist
        echo "-> dev.remote.postgres.mise.plist loaded and will start automaticall!"
    end
    if not launchctl list | grep dev.remote.redis &>/dev/null
        launchctl load ~/Library/LaunchAgents/dev.remote.redis.mise.plist
        echo "-> dev.remote.redis.mise.plist loaded and will start automaticall!"
    end
    
    # Aliases
    abbr -a neo-nld-tests "MIX_ENV=test mix do --app netherlands test"
    abbr -a neo-nld-e2e "MIX_ENV=e2e mix test.e2e apps/neo_web/test/e2e/netherlands"
    abbr -a neo-nld-api-tests "mix test apps/neo_web/test/unit/neo_web/controllers/api/v1/netherlands"
    abbr -a neo-nld-all-tests "MIX_ENV=test mix do --app netherlands test && MIX_ENV=e2e mix test.e2e apps/neo_web/test/e2e/netherlands && mix test apps/neo_web/test/unit/neo_web/controllers/api/v1/netherlands"

    abbr -a neo-ca-tests "MIX_ENV=test mix do --app canada test"
    abbr -a neo-ca-e2e "MIX_ENV=e2e mix test.e2e apps/neo_web/test/e2e/canada"
    abbr -a neo-ca-api-tests "mix test apps/neo_web/test/unit/neo_web/controllers/api/v1/canada"
    abbr -a neo-ca-all-tests "MIX_ENV=test mix do --app canada test && mix test apps/neo_web/test/unit/neo_web/controllers/api/v1/canada && MIX_ENV=e2e mix test.e2e apps/neo_web/test/e2e/canada"

    abbr -a morning-tiger "mix deps.get && mix gen.runtime.dev.secret && mix ecto.reset && mix feature_flags.pull staging && mix phx.server"
    abbr -a compile-tiger "mix deps.get && mix ecto.migrate && mix phx.server"
end
