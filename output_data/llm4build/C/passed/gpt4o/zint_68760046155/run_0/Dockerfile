FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    git \
    make \
    cmake \
    g++ \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Qt5
RUN wget https://download.qt.io/official_releases/qt/5.15/5.15.2/qt-opensource-linux-x64-5.15.2.run -O qt-installer.run && \
    chmod +x qt-installer.run && \
    ./qt-installer.run --platform minimal --script qt-noninteractive.qs && \
    rm qt-installer.run

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]