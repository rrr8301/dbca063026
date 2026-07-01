FROM python:3.14-slim

# Set timezone to Pacific Time (non-interactive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    libhdf5-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Create working directory
WORKDIR /repo

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /repo/run.sh
RUN chmod +x /repo/run.sh

# Set entrypoint
ENTRYPOINT ["/repo/run.sh"]