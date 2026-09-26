FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Install Zulu JDK 17 and 21
RUN wget -qO - https://repos.azul.com/azul-repo.key | apt-key add - && \
    echo "deb http://repos.azul.com/azure-only/zulu/apt stable main" | tee /etc/apt/sources.list.d/zulu.list && \
    apt-get update && \
    apt-get install -y zulu17-jdk zulu21-jdk

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]