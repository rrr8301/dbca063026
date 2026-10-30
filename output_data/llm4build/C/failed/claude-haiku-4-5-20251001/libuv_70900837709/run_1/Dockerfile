FROM alpine:3.23

# Set timezone to Pacific Time and environment variables
ENV TZ=America/Los_Angeles \
    CI=true \
    GITHUB_ACTIONS=true

# Install dependencies
RUN apk add --no-cache \
    build-base \
    cmake \
    linux-headers \
    git \
    tzdata \
    bash

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git safe directory to avoid ownership errors
RUN git config --global --add safe.directory '*'

# Create run.sh with proper line endings (LF only)
RUN printf '#!/bin/bash\nset -e\n\n# Configure CMake build\ncmake -B build -DBUILD_TESTING=ON\n\n# Build the project\ncmake --build build\n\n# Run tests\ncd build && ctest -V --output-on-failure\n' > /run.sh && \
    chmod +x /run.sh

ENTRYPOINT ["/run.sh"]