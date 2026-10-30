FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt update && apt install -y \
    liblzo2-dev libpam0g-dev liblz4-dev linux-libc-dev man2html clang \
    libcmocka-dev python3-docutils python3-jinja2 python3-jsonschema \
    libtool automake autoconf pkg-config libcap-ng-dev libnl-genl-3-dev \
    git cmake gcc make

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]