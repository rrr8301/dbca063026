FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install necessary packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 11.15
RUN curl -fsSL https://deb.nodesource.com/setup_11.x | bash - && \
    apt-get install -y nodejs

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Install npm packages
RUN npm install --save-dev mocha@8.4.0
RUN npm install

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]