#!/usr/bin/env bash
set +e

# ty mdtests (GitHub annotations)
echo "=== Running ty mdtests ==="
cargo test -p ty_python_semantic --test mdtest || true

# Run tests
echo "=== Running main tests ==="
cargo insta test --all-features --unreferenced reject --test-runner nextest --disable-nextest-doctest
TESTS_RESULT=$?

# Run doctests
echo "=== Running doctests ==="
cargo test --doc --all-features
DOCTESTS_RESULT=$?

# Dogfood ty on py-fuzzer
echo "=== Dogfooding ty on py-fuzzer ==="
uv run --project=./python/py-fuzzer cargo run -p ty check --project=./python/py-fuzzer
PY_FUZZER_RESULT=$?

# Dogfood ty on the scripts directory
echo "=== Dogfooding ty on the scripts directory ==="
uv run --project=./scripts cargo run -p ty check --project=./scripts
SCRIPTS_RESULT=$?

# Dogfood ty on ty_benchmark
echo "=== Dogfooding ty on ty_benchmark ==="
uv run --project=./scripts/ty_benchmark cargo run -p ty check --project=./scripts/ty_benchmark
BENCHMARK_RESULT=$?

# Check for broken links in the documentation
echo "=== Running cargo doc --all --no-deps ==="
RUSTDOCFLAGS="-D warnings" cargo doc --all --no-deps
DOC_ALL_RESULT=$?

# Run cargo doc with --document-private-items
echo "=== Running cargo doc with --document-private-items ==="
RUSTDOCFLAGS="-D warnings" cargo doc --no-deps -p ty_python_semantic -p ty_python_core -p ty_module_resolver -p ty_site_packages -p ty_combine -p ty_project -p ty_ide -p ty_wasm -p ty_vendored -p ty_static -p ty -p ty_test -p ruff_db -p ruff_python_formatter --document-private-items
DOC_PRIVATE_RESULT=$?

echo "=== Test Results Summary ==="
echo "Main tests: $TESTS_RESULT"
echo "Doctests: $DOCTESTS_RESULT"
echo "py-fuzzer dogfood: $PY_FUZZER_RESULT"
echo "scripts dogfood: $SCRIPTS_RESULT"
echo "benchmark dogfood: $BENCHMARK_RESULT"
echo "doc --all: $DOC_ALL_RESULT"
echo "doc private: $DOC_PRIVATE_RESULT"

if [ $TESTS_RESULT -eq 0 ] && [ $DOCTESTS_RESULT -eq 0 ] && [ $PY_FUZZER_RESULT -eq 0 ] && [ $SCRIPTS_RESULT -eq 0 ] && [ $BENCHMARK_RESULT -eq 0 ] && [ $DOC_ALL_RESULT -eq 0 ] && [ $DOC_PRIVATE_RESULT -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
