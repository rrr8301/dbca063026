FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install base dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    unzip \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Install OpenJDK 21
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install OpenJDK 25
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-25-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install Maven
RUN apt-get update && apt-get install -y --no-install-recommends \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Create .m2 directory for Maven configuration
RUN mkdir -p /root/.m2

# Create Maven toolchains.xml to define available JDK toolchains
RUN printf '%s\n' \
    '<?xml version="1.0" encoding="UTF-8"?>' \
    '<toolchains>' \
    '  <toolchain>' \
    '    <type>jdk</type>' \
    '    <provides>' \
    '      <version>21</version>' \
    '      <vendor>openjdk</vendor>' \
    '    </provides>' \
    '    <configuration>' \
    '      <jdkHome>/usr/lib/jvm/java-21-openjdk-amd64</jdkHome>' \
    '    </configuration>' \
    '  </toolchain>' \
    '  <toolchain>' \
    '    <type>jdk</type>' \
    '    <provides>' \
    '      <version>25</version>' \
    '      <vendor>openjdk</vendor>' \
    '    </provides>' \
    '    <configuration>' \
    '      <jdkHome>/usr/lib/jvm/java-25-openjdk-amd64</jdkHome>' \
    '    </configuration>' \
    '  </toolchain>' \
    '</toolchains>' > /root/.m2/toolchains.xml

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]