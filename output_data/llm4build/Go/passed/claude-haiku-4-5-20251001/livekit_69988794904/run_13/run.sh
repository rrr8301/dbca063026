if grep -q '"Action":"fail"' /tmp/gotest.log; then
    echo "Tests failed"
    TEST_FAILED=1