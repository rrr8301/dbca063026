# Use a base image with Python pre-installed
FROM python:3.11-slim

# Set the working directory
WORKDIR /app

# Copy the necessary files into the container
COPY . .

# Install any required dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Make the run.sh script executable
RUN chmod +x /app/run.sh

# Set the entrypoint to the run.sh script
ENTRYPOINT ["/app/run.sh"]