# Use an official OpenJDK runtime as a parent image
FROM eclipse-temurin:21-jdk

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install Bazelisk, git, and any necessary dependencies
RUN apt-get update && \
    apt-get install -y curl git && \
    curl -L https://github.com/bazelbuild/bazelisk/releases/download/v1.10.1/bazelisk-linux-amd64 -o /usr/local/bin/bazelisk && \
    chmod +x /usr/local/bin/bazelisk

# Ensure run.sh is executable
RUN chmod +x /app/run.sh

# Run the run.sh script
CMD ["./run.sh"]