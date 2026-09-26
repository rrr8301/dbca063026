# Use a pre-built Python image with a pre-release version of Python 3.14
FROM python:3.14-rc-slim

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install additional dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Configure git
RUN git config --global --add safe.directory '*'

# Install Python dependencies
RUN python -m venv venv && \
    . venv/bin/activate && \
    pip install --upgrade pip && \
    pip install -r requirements_test.txt -r requirements_test_min.txt -r requirements_test_pre_commit.txt

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]