#!/bin/bash

# Clone the repository
git clone <repository-url> /app
cd /app

# Set up Python environment
python3.12 -m venv venv
source venv/bin/activate

# Install Python dependencies if any (placeholder)
# pip install -r requirements.txt

# Set up Java environment (Zulu Java 17 is already installed)

# Run Maven tests
./mvnw -T 4C clean test -P args-for-client-test -Dspring-boot.version=2.7.18 -Dspring-framework-bom.version=5.3.31 -e -B -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn

# Ensure all tests are executed
if [ $? -ne 0 ]; then
  echo "Some tests failed, but continuing with the rest of the script."
fi

# Placeholder for additional commands