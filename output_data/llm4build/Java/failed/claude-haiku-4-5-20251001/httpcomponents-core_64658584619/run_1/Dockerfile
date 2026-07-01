FROM eclipse-temurin:21-jdk-jammy

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required OS-level packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Copy the repository
COPY . .

# Make mvnw and run.sh executable
RUN chmod +x /workspace/mvnw /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]