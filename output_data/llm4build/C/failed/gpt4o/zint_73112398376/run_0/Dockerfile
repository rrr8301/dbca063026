FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    git \
    make \
    cmake \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Qt6
RUN wget https://download.qt.io/official_releases/qt/6.9/6.9.0/qt-opensource-linux-x64-6.9.0.run -O qt-installer.run && \
    chmod +x qt-installer.run && \
    ./qt-installer.run --platform minimal --script qt-noninteractive.qs && \
    rm qt-installer.run

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Configure git
RUN git config --global --add safe.directory '*'

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]