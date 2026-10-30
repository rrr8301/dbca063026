FROM ubuntu:rolling

ENV DEBIAN_FRONTEND=noninteractive
ENV DEVELOPER=1
ENV DEFAULT_TEST_TARGET=prove
ENV GIT_TEST_CLONE_2GB=true
ENV SKIP_DASHED_BUILT_INS=YesPlease
ENV TERM=dumb
ENV MAKEFLAGS=
ENV CUSTOM_PATH=/custom
ENV CI_JOB_IMAGE=ubuntu:rolling
ENV jobname=linux-meson
ENV CC=gcc
ENV PYTHON_PACKAGE=python3
ENV GIT_TEST_HTTPD=true
ENV LINUX_GIT_LFS_VERSION=1.5.2
ENV MESONFLAGS=-Dcredential_helpers=libsecret,netrc
ENV TEST_CONTRIB_TOO=yes
ENV GIT_TEST_USE_SET_E=yes
ENV PATH=/custom:$PATH
ENV GITHUB_ACTIONS=true

# Install basic dependencies
RUN apt-get -q update && \
    apt-get -q -y install \
    language-pack-is apache2 cvs cvsps git gnupg libsvn-perl subversion \
    make libssl-dev libcurl4-openssl-dev libexpat-dev wget sudo default-jre \
    tcl tk gettext zlib1g-dev perl-modules liberror-perl libauthen-sasl-perl \
    libemail-valid-perl libio-pty-perl libio-socket-ssl-perl libnet-smtp-ssl-perl libdbd-sqlite3-perl libcgi-pm-perl \
    libsecret-1-dev libpcre2-dev meson ninja-build pkg-config cargo \
    gcc python3 curl

# Fix sudo for Ubuntu 25.10+ if needed
RUN if test -f /etc/alternatives/sudo; then \
    update-alternatives --set sudo /usr/bin/sudo.ws || true; \
    fi

# Try to fix dirname if using uutils
RUN if test -x /usr/bin/gnudirname; then \
    ln -sfT /usr/bin/gnudirname /usr/bin/dirname; \
    fi

# Create custom path for tools
RUN mkdir -p $CUSTOM_PATH

# Copy repository
COPY repo/ /app/
WORKDIR /app

# Create builder user
RUN useradd -m builder

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
