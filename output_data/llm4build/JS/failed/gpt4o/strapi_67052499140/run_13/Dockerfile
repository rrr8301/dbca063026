# Use an official Node.js runtime as a parent image
FROM node:20

# Set the working directory in the container
WORKDIR /app

# Copy package.json and yarn.lock into the container at /app
COPY package.json yarn.lock ./

# Enable Corepack to manage Yarn versions
RUN corepack enable

# Create a .yarnrc.yml file to set the registry
RUN echo "npmRegistryServer: 'https://registry.yarnpkg.com'" > .yarnrc.yml

# Install dependencies
RUN yarn set version stable
RUN yarn config set enableImmutableInstalls false
RUN yarn install --inline-builds --network-timeout 100000

# Copy the rest of the application code into the container
COPY . .

# Ensure run.sh is executable
RUN chmod +x ./run.sh

# Run the application
CMD ["./run.sh"]