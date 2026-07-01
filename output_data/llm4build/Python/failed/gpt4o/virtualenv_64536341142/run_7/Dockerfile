FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    snapd \
    fish \
    csh \
    curl \
    wget \
    git \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    && apt-get clean

# Install pyenv to manage Python versions
RUN curl https://pyenv.run | bash

# Set environment variables for pyenv
ENV PYENV_ROOT="/root/.pyenv"
ENV PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"

# Initialize pyenv
RUN /bin/bash -c "echo 'export PYENV_ROOT=\"$PYENV_ROOT\"' >> ~/.bashrc && \
    echo 'export PATH=\"$PYENV_ROOT/bin:$PYENV_ROOT/shims:\$PATH\"' >> ~/.bashrc && \
    echo 'eval \"\$(pyenv init --path)\"' >> ~/.bashrc && \
    echo 'eval \"\$(pyenv init -)\"' >> ~/.bashrc && \
    echo 'eval \"\$(pyenv virtualenv-init -)\"' >> ~/.bashrc"

# Install Python 3.10 and 3.14 using pyenv
RUN /bin/bash -c "source ~/.bashrc && pyenv install 3.10.0 && pyenv install 3.14.0 && pyenv global 3.14.0"

# Install pip for both Python versions
RUN /bin/bash -c "source ~/.bashrc && pyenv global 3.10.0 && curl -sS https://bootstrap.pypa.io/get-pip.py | python && \
    pyenv global 3.14.0 && curl -sS https://bootstrap.pypa.io/get-pip.py | python"

# Install uv and tox
RUN /bin/bash -c "source ~/.bashrc && pyenv global 3.14.0 && pip install uv tox>=4.32 tox-uv"

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]