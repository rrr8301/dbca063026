FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV BUILD_TYPE=Release

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    ca-certificates \
    python3 \
    python3-pip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install newer CMake (3.23+)
RUN mkdir -p /opt/cmake && \
    cd /tmp && \
    wget https://github.com/Kitware/CMake/releases/download/v3.27.0/cmake-3.27.0-linux-x86_64.tar.gz && \
    tar -xzf cmake-3.27.0-linux-x86_64.tar.gz && \
    mv cmake-3.27.0-linux-x86_64 /opt/cmake-3.27.0 && \
    rm cmake-3.27.0-linux-x86_64.tar.gz

ENV PATH="/opt/cmake-3.27.0/bin:${PATH}"

# Install Conan
RUN pip3 install conan

WORKDIR /app
COPY repo/ /app/

# Create default Conan profile
RUN conan profile detect

# Install conan dependencies
RUN conan install conanfile.py -s build_type=Release --build=missing

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
