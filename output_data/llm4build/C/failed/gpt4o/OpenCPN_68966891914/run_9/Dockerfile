# Use an official Ubuntu as a parent image
FROM ubuntu:latest

# Set the working directory
WORKDIR /app

# Install necessary packages
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    build-essential

# Copy the run script into the container
COPY run.sh /app/run.sh

# Make the run script executable
RUN chmod +x /app/run.sh

# Run the script
CMD ["/app/run.sh"]