FROM ubuntu:22.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    make \
    gcc \
    g++ \
    libgdbm-dev \
    libdb-dev \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PERL_SKIP_TTY_TEST=1
ENV CONTINUOUS_INTEGRATION=1

# Create work directory
WORKDIR /perl-build

# Copy the entire repository (including .git directory)
COPY . /perl-build/

# Copy run.sh and make it executable
COPY run.sh /perl-build/run.sh
RUN chmod +x /perl-build/run.sh

# Set entrypoint
ENTRYPOINT ["/perl-build/run.sh"]