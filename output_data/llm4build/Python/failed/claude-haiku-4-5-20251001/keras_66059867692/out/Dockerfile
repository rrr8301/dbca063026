FROM python:3.11-slim

# Set timezone to Pacific Time (non-interactive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and setuptools
RUN python -m pip install --upgrade pip setuptools

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Install project dependencies from requirements.txt
RUN pip install -r requirements.txt --progress-bar off --upgrade

# Install tf_keras and remove conflicting packages
RUN pip install --no-deps tf_keras==2.20.0 && \
    pip uninstall -y keras keras-nightly || true

# Install project in editable mode
RUN pip install -e "." --progress-bar off --upgrade

# Install pytest and coverage for testing
RUN pip install pytest pytest-cov coverage

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]