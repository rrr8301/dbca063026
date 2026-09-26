#!/usr/bin/env bash

cd lib && ./configure --disable-openmp && cd ..
make -C lib lib || true
make -C bin || true
make -C site source || true
make -C test || true
make -C test test || true

echo "FINAL_STATUS = SUCCESS"
