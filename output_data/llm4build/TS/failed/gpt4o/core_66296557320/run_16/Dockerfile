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

# Inspect and correct package.json or package-lock.json if necessary
# Use sed command to replace unsupported URLs
RUN sed -i 's/"catalog:/"https:/' package*.json

# Install the application dependencies
# Add --no-audit and --no-fund to avoid network issues related to audit and funding
# Use --legacy-peer-deps to handle peer dependency issues
# Add --force to force install even if there are compatibility issues
# Use --engine-strict=false to bypass engine checks
RUN npm install --legacy-peer-deps --no-audit --no-fund --force --engine-strict=false || \
    (cat /root/.npm/_logs/*-debug.log && exit 1)

# Copy the rest of the application code to the working directory
COPY . .

# Run the test script
CMD ["npm", "run", "test:e2e-test"]