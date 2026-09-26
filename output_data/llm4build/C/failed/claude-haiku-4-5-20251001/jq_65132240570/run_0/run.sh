autoreconf -i
   ./configure --disable-docs --with-oniguruma=builtin --disable-shared --enable-static --enable-all-static CFLAGS="-O2 -pthread -fstack-protector-all -Wl,--stack,8388608"
   make -j$(nproc)
   make check VERBOSE=yes