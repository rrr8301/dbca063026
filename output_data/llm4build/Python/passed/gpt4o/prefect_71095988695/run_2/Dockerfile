FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    git \
    curl \
    wget \
    redis-server \
    python3-pip \
    python3.10-venv

# Add deadsnakes PPA for Python 3.10
RUN add-apt-repository ppa:deadsnakes/ppa && apt-get update && apt-get install -y \
    python3.10

# Create a virtual environment and activate it
RUN python3.10 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install uv within the virtual environment
RUN pip install uv

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Install Python dependencies using uv
RUN uv sync --locked

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]