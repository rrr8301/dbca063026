#!/bin/bash

# Activate pyenv
export PATH="/root/.pyenv/bin:/root/.pyenv/shims:${PATH}"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# Install Python packages for Python 3.12
pyenv shell 3.12.0
pip install numpy cython pytest pytest-xdist pytest-timeout pybind11 mpmath gmpy2 pythran ninja meson pooch hypothesis spin "click<8.3.0"

# Install Python packages for Python 3.14-dev
pyenv shell 3.14-dev
pip install git+https://github.com/numpy/numpy.git
pip install ninja cython pytest pybind11 pytest-xdist pytest-timeout spin pooch hypothesis "setuptools<67.3" meson "click<8.3.0"
pip install git+https://github.com/serge-sans-paille/pythran.git

# Setup build and install scipy
spin build --release

# Ccache performance
ccache --evict-older-than 1d
ccache -s

# Check installed files
spin check --installed-files --no-build

# Check symbol hiding
spin check --symbol-hiding --no-build

# Check usage of install tags
rm -r build-install
spin build --tags=runtime,python-runtime,devel
python tools/check_installation.py build-install --no-tests
rm -r build-install
spin build --tags=runtime,python-runtime,devel,tests
spin check --installed-files --no-build

# Check xp markers
spin check --xp-markers --no-build

# Check build-internal dependencies
ninja -C build -t missingdeps

# Mypy (only for Python 3.12)
pyenv shell 3.12.0
pip install mypy==1.19.1 types-psutil typing_extensions
pip install pybind11 sphinx
spin mypy

# Pyrefly (only for Python 3.12)
pip install -r requirements/dev.txt
pyrefly check --output-format=github

# Test SciPy
export OMP_NUM_THREADS=2
spin test -j3 -- --durations 10 --timeout=60