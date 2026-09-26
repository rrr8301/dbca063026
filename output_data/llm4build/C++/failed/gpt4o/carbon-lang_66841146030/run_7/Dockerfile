# Use a base image with Python 3.10
FROM python:3.10-slim

# Set the working directory
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any necessary dependencies
# Uncomment and modify the following line if you have a requirements.txt
# RUN pip install --no-cache-dir -r requirements.txt

# Make the run.sh script executable
RUN chmod +x /app/run.sh

# Run the script
CMD ["/app/run.sh"]