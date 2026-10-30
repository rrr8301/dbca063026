# Use an official Node.js runtime as a parent image
FROM node:20

# Set the working directory in the container
WORKDIR /app

# Copy package.json and yarn.lock into the container at /app
COPY package.json yarn.lock ./

# Enable Corepack to manage Yarn versions
RUN corepack enable

# Configure Yarn to use the default registry
RUN yarn config set registry https://registry.yarnpkg.com

# Install dependencies
RUN yarn install --immutable --inline-builds

# Copy the rest of the application code into the container
COPY . .

# Ensure run.sh is executable
RUN chmod +x ./run.sh

# Run the application
CMD ["./run.sh"]