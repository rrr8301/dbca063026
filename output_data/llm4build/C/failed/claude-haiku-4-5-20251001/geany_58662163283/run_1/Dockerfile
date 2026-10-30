FROM ubuntu:22.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update -qq && \
    apt-get install --assume-yes --no-install-recommends \
    git \
    build-essential \
    autoconf \
    automake \
    ccache \
    gettext \
    autopoint \
    libtool \
    libgtk-3-dev \
    doxygen \
    python3-docutils \
    python3-lxml \
    rst2pdf \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Make autogen.sh executable
RUN chmod +x /workspace/autogen.sh

# Copy and make run.sh executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]