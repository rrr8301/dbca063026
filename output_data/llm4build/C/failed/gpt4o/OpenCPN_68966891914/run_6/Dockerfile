# Use an official Ubuntu as a parent image
FROM ubuntu:22.04

# Set the working directory
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy the run.sh script into the container
COPY run.sh /app/run.sh

# Make the run.sh script executable
RUN chmod +x /app/run.sh

# Run the run.sh script
CMD ["/app/run.sh"]