FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    gcc \
    libasan8 \
    libstdc++6 \
    mysql-server \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m testuser && echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
WORKDIR /workspace
RUN chown -R testuser /workspace
USER testuser

# Copy the repository
COPY --chown=testuser . /workspace

# Configure git
RUN git config --global --add safe.directory '*'

# Install Python dependencies
RUN python3.11 -m venv /workspace/venv
ENV PATH="/workspace/venv/bin:$PATH"
RUN pip install --upgrade pip

# Install the package from source
RUN CC="gcc -fsanitize=address -fsanitize=undefined -g" pip install .

# MySQL service should be started in the run.sh script, not here