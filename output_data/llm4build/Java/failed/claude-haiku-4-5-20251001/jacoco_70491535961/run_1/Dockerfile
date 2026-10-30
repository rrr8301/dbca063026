FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install base dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    gnupg \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Add Azul's repository for Zulu JDK
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9 || \
    curl -fsSL https://repos.azul.com/azul-repo.key | apt-key add - && \
    apt-add-repository "deb http://repos.azul.com/ubuntu stable main"

# Install Zulu JDK 11 and JDK 17
RUN apt-get update && apt-get install -y --no-install-recommends \
    zulu-11 \
    zulu-17 \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME for JDK 11 (default)
ENV JAVA_HOME=/usr/lib/jvm/zulu-11-amd64
ENV JAVA_HOME_11_X64=/usr/lib/jvm/zulu-11-amd64
ENV JAVA_HOME_17_X64=/usr/lib/jvm/zulu-17-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git to trust the workspace directory
RUN git config --global --add safe.directory '*'

# Copy run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]