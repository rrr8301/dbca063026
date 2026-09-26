FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=UTC
RUN apt-get update && apt-get install -y tzdata && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && dpkg-reconfigure --frontend noninteractive tzdata
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libcppunit-dev \
    libsasl2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Maven
RUN curl -fsSL https://archive.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz | tar -xz -C /opt \
    && ln -s /opt/apache-maven-3.8.6/bin/mvn /usr/bin/mvn

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && chown -R testuser /workspace
USER testuser

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]