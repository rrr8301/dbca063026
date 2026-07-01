FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Install SDKMAN for managing Java versions
RUN curl -s "https://get.sdkman.io" | bash

# Install Java 21 using SDKMAN (assuming Java 21 is available as 21.0.0-zulu)
RUN bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && sdk install java 21.0.0-zulu"

# Set up Gradle
RUN bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && sdk install gradle 7.5"

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]