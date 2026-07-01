FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs

# Install Python 3.11
RUN apt-get update && apt-get install -y python3.11 python3.11-venv python3-pip

# Install Yarn
RUN npm install --global yarn

# Create work directory
WORKDIR /app

# Copy repository files
COPY . .

# Install Python packages
RUN pip install virtualenv

# Install Node.js packages
RUN yarn install

# Install gvisor
RUN curl -L https://github.com/google/gvisor/releases/download/latest/runsc -o /usr/bin/runsc && \
    chmod +x /usr/bin/runsc

# Install Google Chrome and chromedriver
RUN ./buildtools/install_chrome_for_tests.sh -y

# Build Node.js code
RUN yarn run build

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]