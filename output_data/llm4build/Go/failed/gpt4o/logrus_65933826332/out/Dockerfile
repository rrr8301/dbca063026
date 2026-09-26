# Use the official Golang image as the base image
FROM golang:1.23

# Set the working directory inside the container
WORKDIR /app

# Install git
RUN apt-get update && apt-get install -y git

# Copy the run.sh script into the container
COPY run.sh /app/run.sh

# Make the run.sh script executable
RUN chmod +x /app/run.sh

# Run the run.sh script
CMD ["/app/run.sh"]