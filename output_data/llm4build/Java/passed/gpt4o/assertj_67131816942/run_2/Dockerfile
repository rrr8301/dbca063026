FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    maven \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Zulu OpenJDK 25
RUN mkdir -p /etc/apt/keyrings && \
    wget -qO /etc/apt/keyrings/azul.asc https://repos.azul.com/azul-repo.key && \
    echo "deb [signed-by=/etc/apt/keyrings/azul.asc] https://repos.azul.com/zulu/deb stable main" | tee /etc/apt/sources.list.d/zulu.list && \
    apt-get update && \
    apt-get install -y zulu25-jdk

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]