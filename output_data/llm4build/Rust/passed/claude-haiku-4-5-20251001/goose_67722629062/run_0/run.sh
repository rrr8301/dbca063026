gnome-keyring-daemon --components=secrets --daemonize --unlock <<< 'foobar'
    export CARGO_INCREMENTAL=0
    cargo test -- --skip scenario_tests::scenarios::tests
    cargo test --jobs 1 scenario_tests::scenarios::tests