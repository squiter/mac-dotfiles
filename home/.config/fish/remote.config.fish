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
    
    # Aliases
    abbr -a neo-nld-tests "MIX_ENV=test mix do --app netherlands test"
    abbr -a neo-nld-e2e "MIX_ENV=e2e mix test.e2e apps/neo_web/test/e2e/netherlands"
    abbr -a neo-nld-api-tests "mix test apps/neo_web/test/unit/neo_web/controllers/api/v1/netherlands"
    abbr -a neo-nld-all-tests "MIX_ENV=test mix do --app netherlands test && MIX_ENV=e2e mix test.e2e apps/neo_web/test/e2e/netherlands && mix test apps/neo_web/test/unit/neo_web/controllers/api/v1/netherlands"

    abbr -a neo-ca-tests "MIX_ENV=test mix do --app canada test"
    abbr -a neo-ca-e2e "MIX_ENV=e2e mix test.e2e apps/neo_web/test/e2e/canada"
    abbr -a neo-ca-api-tests "mix test apps/neo_web/test/unit/neo_web/controllers/api/v1/canada"
    abbr -a neo-ca-all-tests "MIX_ENV=test mix do --app canada test && mix test apps/neo_web/test/unit/neo_web/controllers/api/v1/canada && MIX_ENV=e2e mix test.e2e apps/neo_web/test/e2e/canada"
end
