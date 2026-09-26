FROM quay.io/gmanka/archlinuxarm:base-devel

ENV GO111MODULE=on
ENV GOFLAGS="-buildvcs=false -tags=next"
WORKDIR /app

COPY repo/ /app/

RUN set -eux; \
    pacman-key --init; \
    sed -i 's/^#DisableSandboxFilesystem/DisableSandboxFilesystem/' /etc/pacman.conf; \
    sed -i 's/^#DisableSandboxSyscalls/DisableSandboxSyscalls/' /etc/pacman.conf; \
    pacman -Syu --noconfirm --needed archlinux-keyring pacman go git gcc make base-devel sudo asciidoc doxygen meson; \
    mkdir -p /app/bin; \
    curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s v2.10.1 -- -b /app/bin; \
    go mod download; \
    rm -rf /var/lib/pacman/sync/* /var/cache/pacman/* /tmp/* /var/tmp/*; \
    rm -rf /usr/share/man/* /usr/share/doc/* || true; \
    yes | pacman -Scc >/dev/null 2>&1 || true

COPY run.sh /run.sh
RUN chmod +x /run.sh
ENTRYPOINT ["/run.sh"]
