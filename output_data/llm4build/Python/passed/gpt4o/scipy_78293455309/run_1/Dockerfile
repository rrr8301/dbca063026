FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install dependencies
RUN apt-get update && apt-get install -y \
    libopenblas-dev libatlas-base-dev liblapack-dev gfortran \
    libgmp-dev libmpfr-dev libsuitesparse-dev ccache libmpc-dev \
    git curl wget cmake ninja-build make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev python3-openssl \
    && rm -rf /var/lib/apt/lists/*

# Install pyenv and Python versions
RUN curl https://pyenv.run | bash
ENV PATH="/root/.pyenv/bin:/root/.pyenv/shims:${PATH}"
RUN /bin/bash -c "source /root/.bashrc && pyenv install 3.12.0 && pyenv install 3.14-dev && pyenv global 3.12.0 3.14-dev"

# Create work directory
WORKDIR /app

# Copy repository
COPY . /app

# Configure git
RUN git config --global --add safe.directory '*'

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]