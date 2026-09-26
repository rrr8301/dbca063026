FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    maven \
    gnupg \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install Zulu JDK 21 (latest LTS version) using Azul's APT repository
RUN wget -qO - https://repos.azul.com/azul-repo.key | gpg --dearmor -o /usr/share/keyrings/azul-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/azul-archive-keyring.gpg] https://repos.azul.com/zulu/deb stable main" | tee /etc/apt/sources.list.d/zulu.list && \
    apt-get update && apt-get install -y zulu21-jdk

# Verify the installation path of Zulu JDK
RUN update-alternatives --install /usr/bin/java java /usr/lib/jvm/zulu-21/bin/java 1 && \
    update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/zulu-21/bin/javac 1

# Correctly set JAVA_HOME to point to the JDK
ENV JAVA_HOME=/usr/lib/jvm/zulu-21
ENV PATH="$JAVA_HOME/bin:$PATH"

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]