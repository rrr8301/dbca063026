FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    python3 \
    gettext \
    fonts-noto \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    fonts-noto-extra \
    fonts-symbola \
    librsvg2-bin \
    texlive \
    texlive-fonts-recommended \
    texlive-lang-arabic \
    texlive-lang-cjk \
    texlive-lang-japanese \
    texlive-luatex \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install development dependencies for building Rust packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust nightly toolchain
RUN rustup toolchain install nightly-2025-09-01 --profile minimal && \
    rustup component add rustfmt --toolchain nightly-2025-09-01

# Install mdbook and related tools using cargo install
RUN cargo install --locked mdbook@0.4.52 && \
    cargo install --locked mdbook-svgbob@0.2.2 && \
    cargo install --locked mdbook-pandoc@0.10.4 && \
    cargo install --locked mdbook-i18n-helpers@0.3.6 && \
    cargo install --locked i18n-report@0.2.0

# Download and install pandoc
RUN curl -LsSf https://github.com/jgm/pandoc/releases/download/3.7.0.1/pandoc-3.7.0.1-linux-amd64.tar.gz | tar zxf - && \
    mv pandoc-3.7.0.1/bin/pandoc /usr/local/bin/ && \
    mv pandoc-3.7.0.1/bin/pandoc-lua /usr/local/bin/ && \
    rm -rf pandoc-3.7.0.1

WORKDIR /app
COPY repo/ /app/

# Install local tools and build
RUN cd /app && \
    cargo install --path mdbook-exerciser --locked && \
    cargo install --path mdbook-course --locked

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
