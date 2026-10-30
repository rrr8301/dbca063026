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

# Copy repository
COPY . .

# Ensure the requirements file exists
# This step is redundant if the file is copied correctly, so we can remove it
# RUN if [ ! -f requirements-dev.txt ]; then echo "requirements-dev.txt not found"; exit 1; fi

# Install Python packages
RUN python3.11 -m pip install --upgrade pip
RUN python3.11 -m pip install -r requirements-dev.txt
RUN python3.11 -m pip install pytest-github-actions-annotate-failures

# Ensure run.sh is executable
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]