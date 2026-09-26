#!/bin/bash

# Modify hosts file for web platform tests server
./test/web-platform-tests/tests/wpt make-hosts-file | sudo tee -a /etc/hosts

# Run tests
npm test