#!/usr/bin/env bash
set -ex

cd /app

# Run the build-linux script
cmake -S . -B build -DCI_MODE=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DREQUIRE_CRYPTO_OPENSSL=1 -DREQUIRE_CRYPTO_GNUTLS=1 \
      -DREQUIRE_SHELLS=1
cmake --build build --verbose -j$(nproc) -- -k
cd build
# Make sure char is signed by default -- see also test-unsigned-char
./qpdf/test_char_sign | grep 'char is signed'
# libtests automatically runs with all crypto providers.
env QPDF_TEST_COMPARE_IMAGES=1 ctest --verbose || true
# Run just qpdf tests with remaining crypto providers.
for i in $(./qpdf/qpdf --show-crypto | tail -n +2); do
    echo "*** Running qpdf tests with crypto provider $i"
    env QPDF_CRYPTO_PROVIDER=$i ctest --verbose -R '^qpdf$' || true
done
cd ..
# Perform additional tests on header files.
./build-scripts/check-headers || true
# Perform additional tests on private header files.
./build-scripts/check-private-headers || true
# Create distribution
export TMPDIR=$PWD/dist-tmp
rm -rf $TMPDIR
./make_dist --ci || true
mkdir -p distribution
cp $TMPDIR/qpdf*-ci.tar.gz distribution 2>/dev/null || true
sha256sum distribution/* 2>/dev/null || true

echo "FINAL_STATUS = SUCCESS"
