# Use an official Maven image as a parent image
FROM maven:3.8.6-openjdk-21

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Make the run.sh script executable
RUN chmod +x /app/run.sh

# Run the run.sh script
CMD ["/app/run.sh"]