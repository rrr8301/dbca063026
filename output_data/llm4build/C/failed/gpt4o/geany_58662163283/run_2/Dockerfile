FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update -qq && \
    apt-get install --assume-yes --no-install-recommends \
    ccache \
    gettext \
    autopoint \
    libtool \
    libgtk-3-dev \
    doxygen \
    python3-docutils \
    python3-lxml \
    rst2pdf \
    git \
    make \
    gcc \
    g++ \
    autoconf \
    automake \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Ensure autogen.sh and gen-signallist.sh are executable
RUN chmod +x autogen.sh scripts/gen-signallist.sh

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]