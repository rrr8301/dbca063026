# Use Eclipse Temurin JDK 21 image as a parent image
FROM eclipse-temurin:21

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install Maven
RUN apt-get update && \
    apt-get install -y maven && \
    rm -rf /var/lib/apt/lists/*

# Make run.sh executable
RUN chmod +x /app/run.sh

# Run the script
CMD ["/app/run.sh"]