FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive \
    MPLBACKEND=Agg \
    NB_KERNEL=python \
    SEABORN_DATA=/app/seaborn-data

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy repo
COPY repo /app/

# Install Python dependencies
RUN pip install --upgrade pip wheel && \
    pip install -e ".[dev,stats]" -r ci/deps_pinned.txt

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
