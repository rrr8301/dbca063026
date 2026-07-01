# Use a Python base image
FROM python:3.13-slim

# Set the working directory
WORKDIR /app

# Copy the project files into the container
COPY . .

# Install Poetry
RUN pip install poetry

# Install project dependencies
RUN poetry install

# Expose the port for Redis (if needed)
EXPOSE 6379

# Set the entrypoint to the run.sh script
ENTRYPOINT ["./run.sh"]