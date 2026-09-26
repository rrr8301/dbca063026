FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set environment variables for CI
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install necessary packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    zip && \  # Corrected the line continuation
    rm -rf /var/lib/apt/lists/*

# Install SDKMAN and use it to install JDK 21
RUN curl -s "https://get.sdkman.io" | bash && \
    bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && sdk install java 21.0.0-librca"

# Create a non-root user
RUN useradd -m testuser
WORKDIR /workspace
RUN chown -R testuser /workspace
USER testuser

# Copy the repository into the container
COPY . /workspace

# Configure git
RUN git config --global --add safe.directory '*'

# Install Gradle
RUN bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && sdk install gradle"

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]