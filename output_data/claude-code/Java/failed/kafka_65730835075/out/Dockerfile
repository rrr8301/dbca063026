FROM eclipse-temurin:23-jdk-noble

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    gnupg \
    software-properties-common \
    python3.12 \
    python3.12-venv \
    python3-pip \
    build-essential \
    jq \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN python3.12 -m pip install --break-system-packages -r .github/scripts/requirements.txt

RUN chmod +x ./gradlew

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
