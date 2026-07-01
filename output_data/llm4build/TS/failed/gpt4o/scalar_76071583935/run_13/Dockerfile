# Use an official Node.js runtime as a parent image
FROM node:20

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and pnpm-lock.yaml to the working directory
COPY package.json pnpm-lock.yaml ./

# Install pnpm
RUN npm install -g pnpm

# Clear pnpm store cache to avoid potential issues
RUN pnpm store prune

# Install project dependencies
# Adding --loglevel=error to reduce verbosity and focus on errors
RUN pnpm install --no-frozen-lockfile --loglevel=error || \
    (echo "Retrying pnpm install without shamefully-hoist" && pnpm install --no-frozen-lockfile --loglevel=error --shamefully-hoist)

# Copy the rest of the application code
COPY . .

# Install Go
RUN wget https://dl.google.com/go/go1.20.5.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.20.5.linux-amd64.tar.gz && \
    rm go1.20.5.linux-amd64.tar.gz

# Set Go environment variables
ENV PATH="/usr/local/go/bin:${PATH}"

# Expose any ports the app is expected to run on
EXPOSE 5051 5052

# Run the application
CMD ["./run.sh"]