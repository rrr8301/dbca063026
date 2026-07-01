FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV GOPROXY=https://proxy.golang.org
ENV GO111MODULE=on
ENV HUGO_BUILD_TAGS=extended,withdeploy
ENV SASS_VERSION=1.80.3
ENV PATH="/root/go/bin:${PATH}"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    pandoc \
    ruby-full \
    ruby-dev \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.25
RUN curl -L https://go.dev/dl/go1.25.10.linux-amd64.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz && \
    /usr/local/go/bin/go version

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/root/go"

# Install Ruby gems
RUN gem install asciidoctor -v "2.0.26" && \
    gem install asciidoctor-diagram -v "3.1.0"

# Install docutils
RUN pip install docutils

# Install Go tools
RUN /usr/local/go/bin/go install github.com/blampe/goat/cmd/goat@177de93b192b8ffae608e5d9ec421cc99bf68402 && \
    /usr/local/go/bin/go install github.com/magefile/mage@v1.15.0

# Install dart-sass for Linux
RUN echo "Install Dart Sass version ${SASS_VERSION} ..." && \
    cd /tmp && \
    curl -LJO "https://github.com/sass/dart-sass/releases/download/${SASS_VERSION}/dart-sass-${SASS_VERSION}-linux-x64.tar.gz" && \
    DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd && \
    echo "${DART_SASS_SHA_LINUX}  dart-sass-${SASS_VERSION}-linux-x64.tar.gz" | sha256sum -c && \
    tar -xvf "dart-sass-${SASS_VERSION}-linux-x64.tar.gz" && \
    mv dart-sass /opt/dart-sass && \
    rm "dart-sass-${SASS_VERSION}-linux-x64.tar.gz"

ENV PATH="/opt/dart-sass:${PATH}"

WORKDIR /root/hugo
COPY repo/ /root/hugo/

# Set up Go cache and dependencies
RUN /usr/local/go/bin/go mod download

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
