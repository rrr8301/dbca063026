FROM ubuntu:22.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    sudo \
    ash \
    csh \
    fish \
    tcsh \
    zsh \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for conda
RUN useradd -m -s /bin/bash conda_user && \
    echo "conda_user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy run.sh and make it executable (before switching user)
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Change ownership to conda_user
RUN chown -R conda_user:conda_user /workspace

# Switch to conda_user
USER conda_user

# Install Miniconda
RUN curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /home/conda_user/miniconda3 && \
    rm /tmp/miniconda.sh

# Initialize conda
ENV PATH="/home/conda_user/miniconda3/bin:$PATH"
RUN conda init --all

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]