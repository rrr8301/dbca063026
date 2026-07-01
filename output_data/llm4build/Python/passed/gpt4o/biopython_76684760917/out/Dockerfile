# Use a pre-built Python image with the desired version
FROM python:3.11-slim

# Set timezone and locale
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    gcc \
    libasan8 \
    libstdc++6 \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m testuser
WORKDIR /workspace
RUN chown -R testuser /workspace
USER testuser

# Copy the repository
COPY --chown=testuser . /workspace

# Configure git
RUN git config --global --add safe.directory '*'

# Install Python dependencies
RUN python3 -m venv /workspace/venv
ENV PATH="/workspace/venv/bin:$PATH"
RUN pip install --upgrade pip

# Install project dependencies
RUN CC="gcc -fsanitize=address -fsanitize=undefined -g" pip install .[test]

# Install coverage
RUN pip install coverage

# Ensure run.sh is executable
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]