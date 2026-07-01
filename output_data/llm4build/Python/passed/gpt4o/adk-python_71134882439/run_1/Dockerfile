FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    && apt-get clean

# Create a working directory
WORKDIR /app

# Copy the repository into the container
COPY . .

# Create and activate a virtual environment, then install pip
RUN python3.12 -m venv /app/.venv
RUN /app/.venv/bin/python -m pip install --upgrade pip

# Install uv within the virtual environment
RUN /app/.venv/bin/pip install uv

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]