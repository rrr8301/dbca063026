# Use a pre-built Python image with Python 3.14
FROM python:3.14-slim

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set up work directory
WORKDIR /app

# Copy the repository
COPY . .

# Install Python dependencies
RUN pip install --upgrade pip \
    && pip install --no-cache-dir setuptools wheel build \
    && pip install --no-cache-dir --extra-index-url https://pypi.anaconda.org/scientific-python-nightly-wheels/simple -e .[test] \
    && pip install --no-cache-dir --extra-index-url https://pypi.anaconda.org/scientific-python-nightly-wheels/simple check-manifest pytest-cov

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]