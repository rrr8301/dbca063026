# Use the official Golang image as a parent image
FROM golang:1.24

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the go.mod and go.sum files to the workspace
COPY go.mod go.sum ./

# Create necessary directories for local replacements
RUN mkdir -p ./hgctl ./external/go-control-plane

# Copy the rest of the application code to the workspace
COPY . .

# Make the run.sh script executable
RUN chmod +x ./run.sh

# Ensure the replacement paths are set up before downloading dependencies
RUN ./run.sh setup

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Run the run.sh script
CMD ["./run.sh"]