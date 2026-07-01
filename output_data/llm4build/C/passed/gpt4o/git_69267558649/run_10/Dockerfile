# Use the specified base image
FROM ubuntu:20.04

# Set environment variables
ENV DEVELOPER=1
ENV CUSTOM_PATH=/custom
ENV CI_TYPE=local

# Install necessary packages
RUN apt-get update && \
    apt-get install -y sudo git && \
    apt-get clean

# Add a non-root user
RUN useradd builder --create-home

# Set the working directory
WORKDIR /app

# Copy the necessary scripts into the container
COPY ci/install-dependencies.sh /app/ci/install-dependencies.sh
COPY ci/run-build-and-tests.sh /app/ci/run-build-and-tests.sh
COPY ci/print-test-failures.sh /app/ci/print-test-failures.sh
COPY ci/lib.sh /app/ci/lib.sh  # Ensure lib.sh is copied
COPY run.sh /app/run.sh

# Make scripts executable
RUN chmod +x /app/ci/install-dependencies.sh /app/ci/run-build-and-tests.sh /app/ci/print-test-failures.sh /app/run.sh

# Run the main script
CMD ["/app/run.sh"]