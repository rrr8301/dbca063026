# Use the official Node.js LTS image
FROM node:lts

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install Node.js dependencies
RUN npm ci

# Copy the rest of the application code
COPY . .

# Make the run.sh script executable
RUN chmod +x ./run.sh

# Run the script
CMD ["./run.sh"]