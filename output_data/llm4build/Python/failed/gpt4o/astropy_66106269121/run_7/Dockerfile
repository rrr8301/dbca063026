FROM python:3.12-slim

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    locales \
    tzdata \
    libbz2-dev \
    libcfitsio-dev \
    git \
    && apt-get clean

# Generate French locale
RUN locale-gen fr_FR.UTF-8

# Set up work directory
WORKDIR /app

# Copy the repository into the container
COPY . .

# Install Python packages
RUN python -m pip install --upgrade pip && \
    python -m pip install tox pytest

# Copy the run script and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]