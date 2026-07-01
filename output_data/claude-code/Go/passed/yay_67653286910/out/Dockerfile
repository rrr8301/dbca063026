FROM quay.io/gmanka/archlinuxarm:base-devel

ENV GO111MODULE=on \
    DEBIAN_FRONTEND=noninteractive \
    GOFLAGS="-buildvcs=false -tags=next"

WORKDIR /app

RUN set -eux; \
    pacman-key --init; \
    sed -i 's/^#DisableSandboxFilesystem/DisableSandboxFilesystem/' /etc/pacman.conf; \
    sed -i 's/^#DisableSandboxSyscalls/DisableSandboxSyscalls/' /etc/pacman.conf; \
    pacman -Syu --noconfirm --needed pacman-contrib git openssh bat go archlinux-keyring pacman git gcc make base-devel sudo asciidoc doxygen meson; \
    curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s v2.10.1; \
    rm -rf /var/lib/pacman/sync/* /var/cache/pacman/* /tmp/* /var/tmp/*; \
    rm -rf /usr/share/man/* /usr/share/doc/* || true; \
    yes | pacman -Scc >/dev/null 2>&1 || true

COPY repo/ /app/

RUN go mod download

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
