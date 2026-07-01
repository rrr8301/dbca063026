FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV GOPROXY=https://proxy.golang.org
ENV GO111MODULE=on
ENV SASS_VERSION=1.80.3
ENV DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd
ENV HUGO_BUILD_TAGS=extended,withdeploy

RUN apt-get update -y && apt-get install -y \
    build-essential \
    git \
    curl \
    wget \
    pandoc \
    python3 \
    python3-pip \
    ruby \
    ruby-dev \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update -y && apt-get install -y \
    autoconf \
    bison \
    patch \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash hugo

WORKDIR /app
COPY repo /app/

RUN wget https://go.dev/dl/go1.26.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.26.0.linux-amd64.tar.gz && \
    rm go1.26.0.linux-amd64.tar.gz

ENV PATH=/usr/local/go/bin:/root/go/bin:$PATH
ENV GOPATH=/root/go

RUN gem install asciidoctor -v "2.0.26"
RUN gem install asciidoctor-diagram -v "3.1.0"

RUN go install github.com/blampe/goat/cmd/goat@177de93b192b8ffae608e5d9ec421cc99bf68402
RUN go install github.com/magefile/mage@v1.15.0
RUN go install github.com/gohugoio/gotmplfmt@latest
RUN go install honnef.co/go/tools/cmd/staticcheck@latest

RUN pip install docutils

RUN curl -L -o /tmp/node.tar.xz https://nodejs.org/dist/v22.0.0/node-v22.0.0-linux-x64.tar.xz && \
    tar -xf /tmp/node.tar.xz -C /usr/local --strip-components=1 && \
    rm /tmp/node.tar.xz

RUN echo "Install Dart Sass version ${SASS_VERSION} ..." && \
    curl -LJO "https://github.com/sass/dart-sass/releases/download/${SASS_VERSION}/dart-sass-${SASS_VERSION}-linux-x64.tar.gz" && \
    echo "${DART_SASS_SHA_LINUX}  dart-sass-${SASS_VERSION}-linux-x64.tar.gz" | sha256sum -c && \
    tar -xvf "dart-sass-${SASS_VERSION}-linux-x64.tar.gz" && \
    mv dart-sass /usr/local/bin/ && \
    rm "dart-sass-${SASS_VERSION}-linux-x64.tar.gz"

ENV PATH=/usr/local/bin/dart-sass:$PATH

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
