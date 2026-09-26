FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    tar \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Go
RUN curl -fsSL https://golang.org/dl/go1.26.0.linux-amd64.tar.gz | tar -C /usr/local -xz
ENV PATH="/usr/local/go/bin:${PATH}"

# Install mongosh
RUN MONGOSH_VERSION="2.5.0" && \
    ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then ARCH="x64"; elif [ "$ARCH" = "aarch64" ]; then ARCH="arm64"; fi && \
    ARCHIVE="mongosh-${MONGOSH_VERSION}-linux-${ARCH}.tgz" && \
    DOWNLOAD_URL="https://downloads.mongodb.com/compass/${ARCHIVE}" && \
    curl -fsSL "${DOWNLOAD_URL}" -o "${ARCHIVE}" && \
    tar -xzf "${ARCHIVE}" && \
    mkdir -p "$HOME/.local/bin" && \
    EXTRACTED_DIR="mongosh-${MONGOSH_VERSION}-linux-${ARCH}" && \
    cp "${EXTRACTED_DIR}/bin/mongosh" "$HOME/.local/bin/mongosh" && \
    chmod +x "$HOME/.local/bin/mongosh" && \
    rm -rf "${EXTRACTED_DIR}" "${ARCHIVE}"

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]