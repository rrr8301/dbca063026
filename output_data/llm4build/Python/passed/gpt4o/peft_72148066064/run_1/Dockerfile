FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install necessary packages
RUN apt-get update && apt-get install -y \
    software-properties-common \
    git \
    sudo \
    python3-pip \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y \
    python3.11 \
    python3.11-venv \
    && apt-get clean

# Set up work directory
WORKDIR /app

# Copy the repository content
COPY . .

# Install Python dependencies
RUN python3.11 -m pip install --upgrade pip setuptools
RUN python3.11 -m pip install -e .[test]

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]