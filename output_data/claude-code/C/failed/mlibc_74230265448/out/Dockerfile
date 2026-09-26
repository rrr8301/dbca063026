FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8

RUN apt-get update && apt-get install -y \
    meson ninja-build qemu-user \
    python3-setuptools python3-jsonschema \
    python3-pexpect python3-pip netbase clang lld \
    git rsync wget patchelf libc6-dev-i386-cross \
    gcc-i686-linux-gnu g++-i686-linux-gnu \
    locales

RUN sed -i 's/^# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && locale-gen

RUN pip install --break-system-packages -U xbstrap pyexpect

WORKDIR /work

RUN mkdir -p src/mlibc build

COPY repo/ src/mlibc/

RUN cp src/mlibc/ci/bootstrap.yml src/ && touch src/mlibc/checkedout.xbstrap

RUN wget -O /tmp/libgcc-x86.a https://github.com/osdev0/libgcc-binaries/releases/latest/download/libgcc-i686.a

WORKDIR /work/build

RUN printf 'define_options:\n  arch: x86\n  compiler: gcc\n  multilib-path: "/usr/i686-linux-gnu"\n' > bootstrap-site.yml

RUN xbstrap init ../src

RUN xbstrap install mlibc

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
