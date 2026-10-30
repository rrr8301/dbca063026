FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
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
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install cargo-binstall
RUN cargo install cargo-binstall

# Install mdbook and pandoc
RUN cargo binstall mdbook --version 0.4.52 --locked
RUN curl -LsSf https://github.com/jgm/pandoc/releases/download/3.7.0.1/pandoc-3.7.0.1-linux-amd64.tar.gz | tar zxf - -C /usr/local/bin --strip-components=1

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and set as entrypoint
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh
ENTRYPOINT ["/usr/local/bin/run.sh"]