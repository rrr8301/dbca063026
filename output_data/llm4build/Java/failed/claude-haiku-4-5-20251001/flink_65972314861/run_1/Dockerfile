FROM chesnay/flink-ci:java_8_11_17_21_maven_386_jammy

# Set timezone to Pacific Time (non-interactive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install additional required packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /root/flink

# Copy the repository
COPY . .

# Copy the run script
COPY run.sh /root/run.sh
RUN chmod +x /root/run.sh

# Set entrypoint
ENTRYPOINT ["/root/run.sh"]