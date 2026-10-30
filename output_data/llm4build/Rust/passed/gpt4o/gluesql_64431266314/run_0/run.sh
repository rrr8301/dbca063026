#!/bin/bash

# Navigate to the macros directory and run tests
cd macros
cargo test --verbose
cd ..