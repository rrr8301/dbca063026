FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    make \
    g++ \
    curl \
    wget \
    python3.14 \
    python3-pip

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Ensure the requirements file exists
RUN if [ ! -f requirements-dev.txt ]; then echo "requirements-dev.txt not found!"; exit 1; fi

# Ensure the CMakeLists.txt file exists in the correct subdirectory
# Adjust the path if CMakeLists.txt is in a subdirectory
RUN if [ ! -f path/to/subdirectory/CMakeLists.txt ]; then echo "CMakeLists.txt not found in subdirectory!"; exit 1; fi

# Install Python dependencies
RUN pip3 install --upgrade pip && pip3 install -r requirements-dev.txt

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]