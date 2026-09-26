FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install --quiet --yes --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    pkg-config \
    cmake \
    make \
    g++ \
    gettext \
    zip \
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
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install cargo-binstall
RUN curl -L --proto '=https' --tlsv1.2 -sSf https://github.com/cargo-bins/cargo-binstall/releases/latest/download/cargo-binstall-x86_64-unknown-linux-musl.tgz | tar zxf - -C /root/.cargo/bin

# Install pandoc
RUN curl -LsSf https://github.com/jgm/pandoc/releases/download/3.7.0.1/pandoc-3.7.0.1-linux-amd64.tar.gz | tar zxf - -C /tmp && \
    mv /tmp/pandoc-3.7.0.1/bin/pandoc /usr/local/bin/ && \
    rm -rf /tmp/pandoc-3.7.0.1

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]