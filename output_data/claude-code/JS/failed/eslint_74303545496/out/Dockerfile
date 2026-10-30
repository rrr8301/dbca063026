FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Node.js 22.x
RUN apt-get update && \
    apt-get install -y \
    curl \
    ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy repository code
COPY repo/ /app/

# Create Makefile symlink (workflow uses "node Makefile" but only Makefile.js exists)
RUN ln -s Makefile.js Makefile

# Install npm dependencies
RUN npm install

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
