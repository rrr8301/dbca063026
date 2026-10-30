# Use the official Node.js 14 image as the base image
FROM node:14

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Set npm to use the default registry to avoid unsupported URL issues
RUN npm config set registry https://registry.npmjs.org/

# Clean npm cache to avoid potential issues
RUN npm cache clean --force

# Install the application dependencies
RUN npm install --legacy-peer-deps

# Copy the rest of the application code to the working directory
COPY . .

# Run the test script
CMD ["npm", "run", "test:e2e-test"]