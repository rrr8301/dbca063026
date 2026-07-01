FROM node:24-bullseye

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install necessary packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    make \
    && rm -rf /var/lib/apt/lists/*

# Enable corepack and install pnpm
RUN npm i -g corepack@latest && corepack enable

# Create and set working directory
WORKDIR /usr/src/app

# Copy repository files
COPY . .

# Install project dependencies
RUN make install

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]