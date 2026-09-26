# Dockerfile
FROM node:23

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create and set working directory
WORKDIR /usr/src/app

# Copy repository files
COPY . .

# Install Node.js dependencies
RUN npm install

# Remove non-test dependencies
RUN npm rm --silent --save-dev connect-redis

# Copy run.sh and make it executable
COPY run.sh /usr/src/app/run.sh
RUN chmod +x /usr/src/app/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/src/app/run.sh"]