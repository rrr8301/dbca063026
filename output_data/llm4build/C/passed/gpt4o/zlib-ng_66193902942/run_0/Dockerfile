FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git cmake g++ make curl wget libgtest-dev libbenchmark-dev python3 python3-venv python3-pip

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Install Python packages
RUN python3 -m pip install gcovr

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]