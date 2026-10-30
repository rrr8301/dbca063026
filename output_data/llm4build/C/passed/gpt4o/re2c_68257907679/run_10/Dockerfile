FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    autoconf \
    automake \
    libtool \
    bison \
    git \
    make \
    g++ \
    curl \
    wget \
    python3 \
    python3-pip \
    python3-venv

# Create a virtual environment for Python
RUN python3 -m venv /opt/venv

# Activate the virtual environment and install Python dependencies
RUN /opt/venv/bin/pip install --upgrade pip && \
    /opt/venv/bin/pip install docutils pygments

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Ensure the configure script is generated
RUN ./autogen.sh

# Ensure the src directory exists
RUN mkdir -p src

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]