FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libgeos-dev \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    libz-dev \
    libexpat1 \
    python3-distutils-extra \
    git \
    make \
    python3.12 \
    python3.12-venv \
    python3-pip

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Install Python dependencies
RUN pip3 install setuptools
RUN pip3 install -r requirements.txt
RUN pip3 install -r requirements-standalone.txt
RUN pip3 install -r requirements-pubsub.txt
RUN pip3 install -r requirements-dev.txt
RUN pip3 install --upgrade https://github.com/geopython/OWSLib/archive/master.zip
RUN pip3 install tox

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]