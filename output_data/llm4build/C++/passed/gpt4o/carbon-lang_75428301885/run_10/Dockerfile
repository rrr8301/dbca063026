# Use a base image with Python pre-installed
FROM python:3.11-slim

# Install git
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the necessary files into the container
COPY . .

# Check if requirements.txt exists and install dependencies if it does
RUN if [ -f requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi

# Make the run.sh script executable
RUN chmod +x /app/run.sh

# Set the entrypoint to the run.sh script
ENTRYPOINT ["/app/run.sh"]