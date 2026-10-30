FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DEVELOPER=1
ENV CC=gcc
ENV CC_PACKAGE=gcc-8
ENV jobname=linux-TEST-vars
ENV CI_JOB_IMAGE=ubuntu:20.04
ENV CUSTOM_PATH=/custom
ENV TEST_OUTPUT_DIRECTORY=/app/t
ENV GITHUB_ACTIONS=false

# Install base packages and dependencies
RUN apt-get update && apt-get install -y \
    git \
    language-pack-is \
    apache2 \
    cvs \
    cvsps \
    gnupg \
    libsvn-perl \
    subversion \
    make \
    libssl-dev \
    libcurl4-openssl-dev \
    libexpat-dev \
    wget \
    sudo \
    default-jre \
    tcl \
    tk \
    gettext \
    zlib1g-dev \
    perl-modules \
    liberror-perl \
    libauthen-sasl-perl \
    libemail-valid-perl \
    libio-pty-perl \
    libio-socket-ssl-perl \
    libnet-smtp-ssl-perl \
    libdbd-sqlite3-perl \
    libcgi-pm-perl \
    libsecret-1-dev \
    libpcre2-dev \
    meson \
    ninja-build \
    pkg-config \
    cargo \
    gcc-8 \
    python2 \
    python3 \
    && apt-get clean

# Set python2 as the preferred python for the build
ENV PYTHON_PATH=/usr/bin/python2
ENV MAKEFLAGS="--jobs=10 CC=gcc PYTHON_PATH=/usr/bin/python2"

# Create CUSTOM_PATH directory
RUN mkdir -p ${CUSTOM_PATH}

# Create builder user
RUN useradd -m builder

# Set up working directory
WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Change ownership to builder
RUN chown -R builder:builder /app ${CUSTOM_PATH}

# Install Perforce tools (optional, may fail gracefully)
RUN mkdir -p ${CUSTOM_PATH} && \
    wget --quiet --directory-prefix="${CUSTOM_PATH}" \
        "https://cdist2.perforce.com/perforce/r23.2/bin.linux26x86_64/p4d" \
        "https://cdist2.perforce.com/perforce/r23.2/bin.linux26x86_64/p4" && \
    chmod a+x "${CUSTOM_PATH}/p4d" "${CUSTOM_PATH}/p4" || true

# Install git-lfs (optional, may fail gracefully)
RUN wget --quiet \
    "https://github.com/github/git-lfs/releases/download/v1.5.2/git-lfs-linux-amd64-1.5.2.tar.gz" && \
    tar -xzf "git-lfs-linux-amd64-1.5.2.tar.gz" \
        -C "${CUSTOM_PATH}" --strip-components=1 \
        "git-lfs-1.5.2/git-lfs" && \
    rm "git-lfs-linux-amd64-1.5.2.tar.gz" || true

# Install JGit (optional, may fail gracefully)
RUN wget --quiet "https://repo1.maven.org/maven2/org/eclipse/jgit/org.eclipse.jgit.pgm/6.8.0.202311291450-r/org.eclipse.jgit.pgm-6.8.0.202311291450-r.sh" \
    --output-document="${CUSTOM_PATH}/jgit" && \
    chmod a+x "${CUSTOM_PATH}/jgit" || true

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
