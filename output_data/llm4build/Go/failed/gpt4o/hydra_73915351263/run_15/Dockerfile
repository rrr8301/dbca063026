# Use an official Golang image as the base
FROM golang:1.20

# Install necessary packages
RUN apt-get update && apt-get install -y \
    softhsm2 \
    opensc \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the run.sh script into the container
COPY run.sh /app/run.sh

# Make the run.sh script executable
RUN chmod +x /app/run.sh

# Copy the Go module files
COPY go.mod go.sum /app/

# Remove problematic lines from go.mod
RUN sed -i '/^tool /d' /app/go.mod

# Download Go module dependencies
RUN go mod tidy

# Copy the rest of the application code
COPY . /app

# Run the script
CMD ["bash", "/app/run.sh"]