# Use an official Golang image as the base image
FROM golang:1.20

# Set the working directory inside the container
WORKDIR /workspace/enterprise/poa

# Copy the go.mod and go.sum files to the working directory
COPY go.mod go.sum ./

# Copy the run.sh script to the working directory
COPY run.sh .

# Make the run.sh script executable
RUN chmod +x run.sh

# Run the script to correct the Go version and download dependencies
RUN ./run.sh setup

# Copy the rest of the application code to the working directory
COPY . .

# Run the tests
CMD ["./run.sh", "test"]