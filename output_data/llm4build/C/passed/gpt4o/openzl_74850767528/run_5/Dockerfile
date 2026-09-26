# Use an official Ubuntu as a parent image
FROM ubuntu:latest

# Set the working directory
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    cmake \
    make \
    g++ \
    python3 \
    python3-pip

# Copy the current directory contents into the container at /app
COPY . /app

# Make run.sh executable
RUN chmod +x /app/run.sh

# Run the script
CMD ["./run.sh"]