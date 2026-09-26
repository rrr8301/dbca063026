FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV file.encoding=UTF-8
ENV MAVEN_OPTS="-Dfile.encoding=UTF-8 -Duser.country=US -Duser.language=en"

RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y openjdk-17-jdk maven && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN chmod +x /app/settings.xml

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
