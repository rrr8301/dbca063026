#!/bin/bash
tox run -e py311-coverage --installpkg `find dist/*.tar.gz`