# Use a pre-built Python image with the desired version
FROM python:3.12-slim

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install additional dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    openjdk-25-jdk \
    gradle \
    && apt-get clean

# Create work directory
WORKDIR /app

# Copy repository files
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r .github/scripts/requirements.txt

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]