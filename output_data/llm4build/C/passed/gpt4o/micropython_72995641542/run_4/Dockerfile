# Dockerfile
FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    git \
    gcc \
    make \
    lcov \
    bash \
    curl \
    wget \
    software-properties-common

# Add deadsnakes PPA for Python 3.11
RUN add-apt-repository ppa:deadsnakes/ppa && apt-get update && apt-get install -y \
    python3.11 \
    python3.11-venv \
    python3.11-dev

# Create work directory
WORKDIR /app

# Copy the repository into the container
COPY . .

# Ensure all scripts have execute permissions
RUN chmod +x /app/run.sh
RUN find /app/tests -name "*.py" -exec chmod +x {} \;

# Set the entrypoint to run.sh
ENTRYPOINT ["/app/run.sh"]