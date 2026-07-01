FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /build

RUN apt-get update && \
    apt-get install -y \
    meson ninja-build qemu-user \
    python3-setuptools python3-jsonschema \
    python3-pexpect python3-pip netbase clang lld \
    git rsync wget patchelf libc6-dev-amd64-cross \
    gcc g++ && \
    pip install --break-system-packages -U xbstrap pyexpect

COPY repo/ /app/

RUN mkdir -p /build/src && \
    cp -r /app /build/src/mlibc && \
    mkdir -p /build/build

WORKDIR /build/src

RUN cp mlibc/ci/bootstrap.yml . && \
    touch mlibc/checkedout.xbstrap

WORKDIR /build/build

RUN echo 'define_options:' > bootstrap-site.yml && \
    echo '  arch: x86_64' >> bootstrap-site.yml && \
    echo '  compiler: gcc' >> bootstrap-site.yml && \
    echo '  multilib-path: "/usr/x86_64-linux-gnu"' >> bootstrap-site.yml

RUN xbstrap init ../src

RUN wget -O /tmp/libgcc-x86_64.a https://github.com/osdev0/libgcc-binaries/releases/latest/download/libgcc-x86_64.a

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
