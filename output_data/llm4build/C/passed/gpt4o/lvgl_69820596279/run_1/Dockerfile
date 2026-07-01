FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    sudo \
    cmake \
    make \
    g++ \
    python3.12 \
    python3.12-venv \
    python3-pip

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Create and activate a virtual environment
RUN python3.12 -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

# Install Python dependencies within the virtual environment
RUN pip install --no-cache-dir -r docs/requirements.txt

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]