# Use an official Maven image with JDK 17 as a parent image
FROM maven:3.8.5-openjdk-17

# Set the working directory inside the container
WORKDIR /app

# Copy the Maven settings file if it exists
COPY .mvn/settings.xml /app/.mvn/settings.xml

# Copy the rest of the application source code
COPY . /app

# Make the run script executable
RUN chmod +x /app/run.sh

# Set the entry point to the run script
ENTRYPOINT ["/app/run.sh"]