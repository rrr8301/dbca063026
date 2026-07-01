#!/usr/bin/env bash
set -e

export TEST_CONTRIB_TOO=yes
export GIT_TEST_USE_SET_E=yes
export MESONFLAGS="-Dcredential_helpers=libsecret,netrc"
export TEST_OUTPUT_DIRECTORY=/app/t
export GIT_TEST_OPTS="--verbose-log -x"
export JOBS=10
export MAKEFLAGS="--jobs=$JOBS CC=gcc"
export GIT_PROVE_OPTS="--timer --jobs $JOBS"

cd /app

# Run build and tests
echo "::group::Configure"
set -x
meson setup build . \
  --fatal-meson-warnings \
  --warnlevel 2 --werror \
  --wrap-mode nofallback \
  -Dfuzzers=true \
  -Dtest_output_directory="${TEST_OUTPUT_DIRECTORY}" \
  $MESONFLAGS
set +x
echo "::endgroup::"

echo "::group::Build"
set -x
meson compile -C build --
set +x
echo "::endgroup::"

echo "::group::Run tests"
set -x
meson test -C build --print-errorlogs --test-args="$GIT_TEST_OPTS" || {
  ./t/aggregate-results.sh "${TEST_OUTPUT_DIRECTORY}/test-results" || true
  FINAL_STATUS=FAIL
  exit 1
}
set +x
echo "::endgroup::"

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS = $FINAL_STATUS"
