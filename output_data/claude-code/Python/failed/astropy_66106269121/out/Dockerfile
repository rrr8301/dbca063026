FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    tzdata \
    libbz2-dev \
    libcfitsio-dev \
    curl \
    wget \
    ca-certificates \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Install French locale
RUN echo "fr_FR.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Upgrade pip
RUN python -m pip install --upgrade pip setuptools wheel

# Install tox
RUN pip install tox tox-uv

# Create app directory
WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Install the package and its dependencies via tox
# This will install all dependencies needed for the test environment
RUN python -m pip install -e ".[all,test]"

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
