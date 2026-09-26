FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies including Java
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install OpenJDK 25 or use a different Java source
RUN apt-get update && apt-get install -y \
    openjdk-25-jdk \
    2>/dev/null || true

# If OpenJDK isn't available, install Java 21 as fallback (which should be available)
RUN java -version 2>/dev/null || \
    (apt-get update && apt-get install -y \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*)

# Set working directory
WORKDIR /app

# Copy repository
COPY repo/ /app/

# Copy and run the test script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
