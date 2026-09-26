FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    lcov \
    cflow \
    ruby \
    doxygen \
    build-essential \
    unifdef \
    software-properties-common \
    python3-pip \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y python3.8 \
    && apt-get clean

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Initialize and update submodules
RUN git submodule update --init --recursive

# Copy and set permissions for run.sh
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]