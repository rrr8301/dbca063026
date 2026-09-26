FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
RUN echo "UTC" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    git curl wget pandoc tzdata ca-certificates && \
    rm -rf /var/lib/apt/lists/*

ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install Go
RUN curl -sSL https://golang.org/dl/go1.23.0.linux-amd64.tar.gz | tar -C /usr/local -xz
ENV PATH="/usr/local/go/bin:${PATH}"

# Install Node
RUN curl -sL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs

# Install Ruby
RUN apt-get install -y ruby-full && \
    gem install asciidoctor -v "2.0.26" && \
    gem install asciidoctor-diagram -v "3.1.0"

# Install Python
RUN apt-get install -y python3 python3-pip && \
    pip3 install docutils

# Install Go tools
RUN /usr/local/go/bin/go install github.com/blampe/goat/cmd/goat@177de93b192b8ffae608e5d9ec421cc99bf68402 && \
    /usr/local/go/bin/go install github.com/magefile/mage@v1.15.0 && \
    /usr/local/go/bin/go install github.com/gohugoio/gotmplfmt@latest && \
    /usr/local/go/bin/go install honnef.co/go/tools/cmd/staticcheck@latest

# Install Dart Sass
RUN curl -LJO "https://github.com/sass/dart-sass/releases/download/1.80.3/dart-sass-1.80.3-linux-x64.tar.gz" && \
    echo "7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd  dart-sass-1.80.3-linux-x64.tar.gz" | sha256sum -c && \
    tar -xvf "dart-sass-1.80.3-linux-x64.tar.gz" && \
    mv dart-sass /usr/local/bin/ && \
    ln -s /usr/local/bin/dart-sass/sass /usr/local/bin/sass

WORKDIR /workspace
COPY . /workspace
RUN git config --global --add safe.directory '*'

COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

RUN useradd -m testuser && chown -R testuser /workspace
USER testuser

# Ensure Go tools are in the PATH for testuser
ENV PATH="/usr/local/go/bin:/home/testuser/go/bin:${PATH}"

ENTRYPOINT ["/usr/local/bin/run.sh"]