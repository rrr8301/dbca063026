FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    xz-utils \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create nixbld group and users for Nix
RUN groupadd -g 30000 nixbld && \
    for i in {1..10}; do useradd -c "Nix build user $i" -d /var/empty -g nixbld -G nixbld -M -N -r -s /sbin/nologin nixbld$i; done

# Install Nix
RUN mkdir -m 0755 /nix && chown root /nix && \
    curl -L https://nixos.org/nix/install | bash -s -- --no-daemon && \
    mkdir -p /etc/nix && \
    echo "build-users-group = nixbld" > /etc/nix/nix.conf && \
    echo "sandbox = false" >> /etc/nix/nix.conf

# Source Nix environment for subsequent RUN commands
ENV PATH=/root/.nix-profile/bin:/root/.nix-profile/sbin:$PATH

WORKDIR /app
COPY repo/ /app/

# Copy and run the test script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
