FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV JDK_DISTRIBUTION=corretto
ENV CI_JDK_MAJOR_VERSION=21
ENV MAVEN_OPTS="-Xss1500k -Xmx2048m -XX:+UnlockDiagnosticVMOptions -XX:+IgnoreUnrecognizedVMOptions -XX:GCLockerRetryAllocationCount=100 -Daether.connector.http.reuseConnections=false -Daether.connector.requestTimeout=60000 -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.class=standard -Dmaven.wagon.http.retryHandler.count=3 -Dmaven.wagon.http.retryHandler.requestSentEnabled=true -Dmaven.wagon.http.serviceUnavailableRetryStrategy.class=standard -Dmaven.wagon.rto=60000"

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    git \
    build-essential \
    pkg-config \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fL https://apt.corretto.aws/corretto.key | apt-key add - && \
    echo "deb https://apt.corretto.aws stable main" > /etc/apt/sources.list.d/corretto.list && \
    apt-get update && \
    apt-get install -y java-21-amazon-corretto-jdk && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

RUN apt-get update && apt-get install -y \
    maven \
    && rm -rf /var/lib/apt/lists/*

RUN mvn -B -ntp -Dscan=false -DskipTests clean install -Pcore-modules,-main 2>&1 | tail -50 || true

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
