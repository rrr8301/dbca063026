FROM python:3.11-slim

# Set timezone to Pacific Time (non-interactive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set environment variables
ENV FORCE_COLOR=1
ENV DEBIAN_FRONTEND=noninteractive
ENV UV_PYTHON_DOWNLOADS=never

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.cargo/bin:$PATH"

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Install the project using uv
RUN /root/.cargo/bin/uv pip install --system .

# Install nox
RUN /root/.cargo/bin/uv pip install --system nox

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]