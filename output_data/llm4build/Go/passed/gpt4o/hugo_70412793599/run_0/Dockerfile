FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    gcc \
    make \
    pandoc \
    && rm -rf /var/lib/apt/lists/*

# Install Go
RUN wget https://golang.org/dl/go1.25.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.25.0.linux-amd64.tar.gz && \
    rm go1.25.0.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# Install Ruby
RUN apt-get update && apt-get install -y ruby-full && rm -rf /var/lib/apt/lists/*

# Install Python
RUN apt-get update && apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/*

# Install Ruby gems
RUN gem install asciidoctor -v "2.0.26" && \
    gem install asciidoctor-diagram -v "3.1.0"

# Install Python packages
RUN pip3 install docutils

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Install Go packages
RUN go install github.com/blampe/goat/cmd/goat@177de93b192b8ffae608e5d9ec421cc99bf68402 && \
    go install github.com/magefile/mage@v1.15.0

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]