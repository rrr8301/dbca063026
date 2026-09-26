#!/usr/bin/env bash
set -e

cd /root/hugo

echo "=== Hugo CI Test Reproduction ==="
echo "Go version:"
go version

echo ""
echo "Mage version:"
mage -version

echo ""
echo "Sass version:"
sass --version

echo ""
echo "Ruby version:"
ruby --version

echo ""
echo "Python version:"
python3 --version

echo ""
echo "Pandoc version:"
pandoc --version

echo ""
echo "=== Running Mage Test ==="
export HUGO_BUILD_TAGS=extended,withdeploy

if mage -v test; then
    echo ""
    echo "FINAL_STATUS = SUCCESS"
else
    echo ""
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
