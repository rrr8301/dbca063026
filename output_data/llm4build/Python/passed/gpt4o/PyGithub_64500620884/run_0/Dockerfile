# Dockerfile
FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install necessary packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    python3.11 \
    python3.11-venv \
    python3-pip

# Create a working directory
WORKDIR /app

# Copy the repository into the container
COPY . .

# Install Python packages
RUN python3.11 -m pip install --upgrade pip && \
    pip install tox tox-gh-actions

# Copy the run.sh script and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set the entrypoint
ENTRYPOINT ["/app/run.sh"]