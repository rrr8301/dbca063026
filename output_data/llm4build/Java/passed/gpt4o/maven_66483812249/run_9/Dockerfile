# Use an official OpenJDK 21 image as a parent image
FROM eclipse-temurin:21-jdk

# Install Maven 3.9.x
RUN apt-get update && \
    apt-get install -y wget && \
    wget https://archive.apache.org/dist/maven/maven-3/3.9.4/binaries/apache-maven-3.9.4-bin.tar.gz && \
    tar xzvf apache-maven-3.9.4-bin.tar.gz -C /opt && \
    ln -s /opt/apache-maven-3.9.4 /opt/maven && \
    ln -s /opt/maven/bin/mvn /usr/bin/mvn && \
    rm apache-maven-3.9.4-bin.tar.gz && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Make the run.sh script executable
RUN chmod +x /app/run.sh

# Run the run.sh script
CMD ["/app/run.sh"]