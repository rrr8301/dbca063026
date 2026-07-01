FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    ca-certificates \
    apt-transport-https \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/lib/jvm && \
    cd /tmp && \
    curl -fsSL -o java25.tar.gz "https://api.adoptium.net/v3/binary/latest/25/ga/linux/x64/jdk/hotspot/normal/eclipse?project=jdk" || \
    curl -fsSL -o java25.tar.gz "https://builds.shipilev.net/jdk25u/openjdk-25-latest-linux-x64.tar.gz" || \
    echo "Java 25 download attempt failed, proceeding with Java 21"

RUN cd /tmp && \
    if [ -f java25.tar.gz ] && file java25.tar.gz | grep -q "gzip"; then \
      tar -xzf java25.tar.gz -C /usr/lib/jvm/ 2>/dev/null || true; \
      rm -f java25.tar.gz; \
      ls -la /usr/lib/jvm/ | grep -i jdk; \
    fi

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 \
    PATH=$JAVA_HOME/bin:$PATH

RUN mkdir -p /root/.m2

COPY toolchains.xml /root/.m2/toolchains.xml

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh

RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
