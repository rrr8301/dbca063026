# Use an official Golang runtime as a parent image
FROM golang:1.17

# Set the working directory inside the container
WORKDIR /app

# Copy the run.sh script into the container
COPY run.sh /app/run.sh

# Make the run.sh script executable
RUN chmod +x /app/run.sh

# Set the entrypoint to run.sh
ENTRYPOINT ["/app/run.sh"]