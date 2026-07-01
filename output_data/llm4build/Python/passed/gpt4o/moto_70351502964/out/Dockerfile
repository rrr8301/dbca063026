FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    sudo \
    python3.11 \
    python3.11-venv \
    python3-pip

# Create work directory
WORKDIR /app

# Copy only the requirements file first to leverage Docker cache
# Ensure the path to requirements-dev.txt is correct
COPY requirements-dev.txt /app/

# Install Python packages
RUN python3.11 -m pip install --upgrade pip
RUN python3.11 -m pip install -r /app/requirements-dev.txt
RUN python3.11 -m pip install pytest-github-actions-annotate-failures

# Copy the rest of the application code
COPY . .

# Ensure run.sh is executable
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]